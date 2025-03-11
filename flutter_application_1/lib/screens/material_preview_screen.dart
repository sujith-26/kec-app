import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:universal_html/html.dart' as html;
import 'dart:io' show File;
import 'dart:convert';
import 'dart:typed_data'; // Added
import '../models/study_material.dart';
import '../utils/web_utils.dart';

class MaterialPreviewScreen extends StatefulWidget {
  final StudyMaterial material;
  final Future<void> Function(String, String, BuildContext) onDownload;

  const MaterialPreviewScreen({super.key, required this.material, required this.onDownload});

  @override
  State<MaterialPreviewScreen> createState() => MaterialPreviewScreenState();
}

class MaterialPreviewScreenState extends State<MaterialPreviewScreen> {
  bool _isLoading = true;
  String? _filePath;
  String? _errorMessage;
  Uint8List? _fileBytes;

  @override
  void initState() {
    super.initState();
    _loadFileForPreview();
  }

  Future<void> _loadFileForPreview() async {
    try {
      debugPrint('Starting preview for URL: ${widget.material.fileUrl}');
      final response = await http.get(Uri.parse(widget.material.fileUrl));
      debugPrint('Preview HTTP Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load file: HTTP ${response.statusCode}');
      }

      final extension = widget.material.fileUrl.split('.').last.split('?')[0].toLowerCase();
      debugPrint('File extension: $extension');
      debugPrint('File size: ${response.bodyBytes.length} bytes');

      if (kIsWeb) {
        if (extension == 'pdf') {
          registerViewFactory('pdf-preview-${widget.material.id}', widget.material.fileUrl);
        }
        _fileBytes = response.bodyBytes;
        setState(() => _isLoading = false);
      } else {
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = '${tempDir.path}/${widget.material.subjectName}.$extension';
        final file = File(tempFilePath);
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('Mobile: File saved to $tempFilePath');
        setState(() {
          _filePath = tempFilePath;
          _fileBytes = response.bodyBytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Preview error: $e');
      setState(() {
        _errorMessage = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material.subjectName, style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => widget.onDownload(widget.material.fileUrl, widget.material.subjectName, context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00246B)))
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 18)))
              : _buildPreview(),
    );
  }

  Widget _buildPreview() {
    final extension = widget.material.fileUrl.split('.').last.split('?')[0].toLowerCase();
    debugPrint('Building preview for extension: $extension');

    if (kIsWeb) {
      switch (extension) {
        case 'pdf':
          debugPrint('Rendering PDF preview for web with iframe');
          return SizedBox.expand(child: HtmlElementView(viewType: 'pdf-preview-${widget.material.id}'));
        case 'jpg':
        case 'png':
          debugPrint('Rendering image preview for web');
          if (_fileBytes == null) {
            return Center(child: Text('Image data not loaded', style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return Image.memory(_fileBytes!, fit: BoxFit.contain);
        case 'txt':
          debugPrint('Rendering text preview for web');
          if (_fileBytes == null) {
            return Center(child: Text('Text data not loaded', style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(utf8.decode(_fileBytes!), style: GoogleFonts.poppins(color: const Color(0xFF00246B))),
          );
        default:
          debugPrint('Unsupported file type for web: $extension');
          return Center(
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(widget.material.fileUrl)),
              child: Text('Open in Browser', style: GoogleFonts.poppins()),
            ),
          );
      }
    } else {
      switch (extension) {
        case 'pdf':
          debugPrint('Rendering PDF preview for mobile: $_filePath');
          if (_filePath == null) {
            return Center(child: Text('PDF file not loaded', style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return PDFView(filePath: _filePath!, enableSwipe: true, swipeHorizontal: true, autoSpacing: true, pageFling: true);
        case 'jpg':
        case 'png':
          debugPrint('Rendering image preview for mobile: $_filePath');
          if (_filePath == null) {
            return Center(child: Text('Image file not loaded', style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return Image.file(File(_filePath!), fit: BoxFit.contain);
        case 'txt':
          debugPrint('Rendering text preview for mobile');
          if (_fileBytes == null) {
            return Center(child: Text('Text data not loaded', style: GoogleFonts.poppins(color: const Color(0xFF00246B))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(utf8.decode(_fileBytes!), style: GoogleFonts.poppins(color: const Color(0xFF00246B))),
          );
        default:
          debugPrint('Unsupported file type for mobile: $extension');
          return Center(
            child: ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(widget.material.fileUrl)),
              child: Text('Open in Browser', style: GoogleFonts.poppins()),
            ),
          );
      }
    }
  }
}