import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const VisuNoteApp());
}

class VisuNoteApp extends StatelessWidget {
  const VisuNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF5146E5);

    return MaterialApp(
      title: 'VisuNote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;

    setState(() => _isPicking = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2400,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open image: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  void _processImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Image processing will be connected to our AI backend next.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _imageBytes != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5146E5),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VisuNote',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF20213A),
                  ),
                ),
                Text(
                  'Your ideas, understood.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF77798C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Turn images into ideas.',
              style: TextStyle(
                fontSize: 29,
                height: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF20213A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Capture handwritten notes, equations, diagrams '
              'or documents. Let AI help you understand them.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF77798C),
              ),
            ),
            const SizedBox(height: 28),

            // Image selection and preview area.
            Container(
              constraints: const BoxConstraints(minHeight: 210),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE5E7F0),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16, 14, 8, 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16865A),
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Image selected',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove image',
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 180,
                            maxHeight: 360,
                          ),
                          color: const Color(0xFFF0F1F7),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            _imageName ?? 'Selected image',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF77798C),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.document_scanner_rounded,
                              size: 34,
                              color: Color(0xFF5146E5),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Start with an image',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF20213A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Choose a photo or capture something new.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF77798C),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Camera button.
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Take a Photo'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5146E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Gallery button.
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isPicking
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5146E5),
                  side: const BorderSide(
                    color: Color(0xFFD9D6FF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            if (_isPicking) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],

            if (hasImage) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _processImage,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Process Image'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16865A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 28),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 15,
                  color: Color(0xFF9294A5),
                ),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Your selected image is previewed on your device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9294A5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
