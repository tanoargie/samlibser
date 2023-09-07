import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.bookPath});

  final String bookPath;

  @override
  Widget build(BuildContext context) {
    final EpubController epubController =
        EpubController(document: EpubDocument.openAsset(bookPath));

    return Scaffold(
      appBar: AppBar(
        // Show actual chapter name
        title: EpubViewActualChapter(
            controller: epubController,
            builder: (chapterValue) => Text(
                  "Chapter: ${chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? ''}",
                  textAlign: TextAlign.start,
                )),
      ),
      // Show table of contents
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: epubController,
        ),
      ),
      // Show epub document
      body: EpubView(
        controller: epubController,
      ),
    );
  }
}
