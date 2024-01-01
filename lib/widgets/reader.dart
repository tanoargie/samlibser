import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen(
      {super.key,
      required this.book,
      required this.updatePositionCallback,
      this.cfi});

  final EpubBook book;
  final String? cfi;
  final Function(String lastCfi) updatePositionCallback;

  @override
  Widget build(BuildContext context) {
    final EpubController epubController =
        EpubController(document: Future.value(book), epubCfi: cfi);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                String lastCfi = epubController.generateEpubCfi() ?? "";
                updatePositionCallback(lastCfi);
                Navigator.of(context).pop(false);
              }),
          title: EpubViewActualChapter(
            controller: epubController,
            builder: (chapterValue) {
              final String chapter =
                  chapterValue?.chapterNumber.toString() ?? '';

              return RichText(
                text: TextSpan(
                    text: chapter,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              );
            },
          )),
      endDrawer: Drawer(
        child: EpubViewTableOfContents(
          controller: epubController,
        ),
      ),
      body: EpubView(
        controller: epubController,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
                textStyle: TextStyle(fontSize: 16, height: 1)),
            chapterDividerBuilder: (epubChapter) => const SizedBox.shrink()),
      ),
    );
  }
}
