import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dylan's Image to PDF Converter",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<PlatformFile> _selectedFiles = [];
  bool _fillPage = true;
  bool _isLoading = false;

  void _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();
    for (var file in _selectedFiles) {
      final imageBytes =
          kIsWeb ? file.bytes! : await File(file.path!).readAsBytes();
      pdf.addPage(
        pw.Page(
          pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(0)),
          build: (pw.Context context) {
            return pw.Image(
              pw.MemoryImage(imageBytes),
              fit: _fillPage ? pw.BoxFit.cover : pw.BoxFit.contain,
            );
          },
        ),
      );
    }
    return pdf.save();
  }

  void _saveAndSharePdf() async {
    if (_selectedFiles.isEmpty || _isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final pdfBytes = await _generatePdfBytes();
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/dylan_converter.pdf').create();
      await file.writeAsBytes(pdfBytes);

      final xFile = XFile(file.path, name: "Dylan's Converted PDF.pdf");
      await Share.shareXFiles([xFile], text: 'Here is my PDF!');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Images Selected',
            style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap 'Select Images' to begin.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png'),
        ),
        title: const Text("Dylan's Converter"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (_selectedFiles.isNotEmpty && !_isLoading)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearSelection,
              tooltip: 'Clear Selection',
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text('Select Images'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Fill Page (may crop images)'),
                  value: _fillPage,
                  onChanged: _isLoading
                      ? null
                      : (bool value) {
                          setState(() {
                            _fillPage = value;
                          });
                        },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedFiles.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: kIsWeb ? 6 : 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _selectedFiles.length,
                            itemBuilder: (context, index) {
                              final file = _selectedFiles[index];
                              final imageWidget = kIsWeb
                                  ? Image.memory(file.bytes!, fit: BoxFit.cover)
                                  : Image.file(File(file.path!), fit: BoxFit.cover);

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  imageWidget,
                                  if (!_isLoading)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                          onPressed: () {
                                            _removeImage(index);
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          tooltip: 'Remove Image',
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveAndSharePdf,
                    icon: const Icon(Icons.share),
                    label: const Text('Share PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}