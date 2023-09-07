import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epub_view/epub_view.dart';
import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:samlibser/widgets/reader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samlibser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Upload book'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File newFile;
  late EpubBook epubBook;

  void _fileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );

    if (result != null) {
      File newFile = File(result.files.single.path ?? '');
      List<int> bytes = await newFile.readAsBytes();
      epubBook = await EpubReader.readBook(bytes);
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const ReadingScreen(bookPath: 'harry.epub')));
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(text: TextSpan(text: epubBook?.Title ?? '')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fileUpload,
        tooltip: 'File upload',
        child: const Icon(Icons.add),
      ),
    );
  }
}
