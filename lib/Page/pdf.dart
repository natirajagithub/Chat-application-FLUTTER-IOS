import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPage extends StatefulWidget {
  final String uri;
  final String name;

  PdfViewerPage({Key? key, required this.uri, required this.name, required pdfUrl}) : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late File? Pfile; // Declare Pfile as nullable File
  late XFile? XPfile; // Declare XPfile as nullable XFile
  bool isLoading = true; // Start with isLoading set to true

  @override
  void initState() {
    super.initState();
    loadNetwork(widget.uri);
  }

  Future<void> loadNetwork(String uri) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(uri));
      final bytes = response.bodyBytes;
      final filename = basename(uri);
      final dir = await getApplicationDocumentsDirectory();
      var file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        Pfile = file;
        XPfile = XFile(file.path);
        isLoading = false;
      });

      print('PDF loaded successfully: ${Pfile!.path}');
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        isLoading = false;
      });
      // Handle error: show an alert, toast, or retry option
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<void> downloadPDF(BuildContext context, String url, String fileName) async {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String dirloc = "";

      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          dirloc = "/sdcard/download/";
        } else {
          dirloc = (await getApplicationDocumentsDirectory()).path;
        }
      } else {
        dirloc = (await getApplicationDocumentsDirectory()).path;
      }

      var file = File('$dirloc/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        Pfile = file;
        XPfile = XFile(file.path);
      });

      print('PDF downloaded to: ${Pfile!.path}');
    } else {
      print('Failed to download PDF: ${response.statusCode}');
    }
  }

  void _downloadFile(BuildContext context) async {
    if (await _requestPermissions()) {
      setState(() {
        isLoading = true;
      });
      await downloadPDF(context, widget.uri, '${widget.name}.pdf');
      setState(() {
        isLoading = false;
      });

      if (Pfile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded successfully...')),
        );
      }
    }
  }

  void _launchURL() async {
    // Implement sharing logic here
    // Example using share_plus:
    // await Share.shareFiles([XPfile!.path], text: 'Sharing PDF');
    print('Sharing PDF: ${XPfile!.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4F9A75),
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _launchURL,
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _downloadFile(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Pfile != null
          ? PDFView(
        filePath: Pfile!.path,
      )
          : Center(child: Text('PDF not loaded')),
    );
  }
}
