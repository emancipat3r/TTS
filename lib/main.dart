import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PdfDocument? _pdfDocument;
  int _currentPage = 1;
  FlutterTts _flutterTts = FlutterTts();

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      PdfDocument? doc = await PdfDocument.openData(fileBytes);
      setState(() {
        _pdfDocument = doc;
        _currentPage = 1;
      });
    }
  }

  Future<void> _readPage() async {
    if (_pdfDocument == null) return;

    PdfPage page = await _pdfDocument!.getPage(_currentPage);
    String text = await page.text;
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Reader and TTS'),
      ),
      body: Center(
        child: _pdfDocument == null
            ? Text('No PDF loaded')
            : Text('Page $_currentPage of ${_pdfDocument!.pageCount}'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickPDF,
            tooltip: 'Open PDF',
            child: Icon(Icons.open_in_browser),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            tooltip: 'Previous Page',
            child: Icon(Icons.arrow_back),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _pdfDocument != null &&
                    _currentPage < _pdfDocument!.pageCount
                ? () => setState(() => _currentPage++)
                : null,
            tooltip: 'Next Page',
            child: Icon(Icons.arrow_forward),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _readPage,
            tooltip: 'Read Page',
            child: Icon(Icons.record_voice_over),
          ),
        ],
      ),
    );
  }
}
