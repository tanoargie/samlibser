import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key, required this.book});

  final EpubBook book;

  @override
  Widget build(BuildContext context) {
    final EpubController epubController =
        EpubController(document: Future.value(book));

    return Scaffold(
      appBar: AppBar(
          title: EpubViewActualChapter(
        controller: epubController,
        builder: (chapterValue) {
          final String chapter =
              chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? '';

          return RichText(
            text: TextSpan(
                text: chapter,
                style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 0.5)),
          );
        },
      )),
      drawer: Drawer(
        child: EpubViewTableOfContents(
          controller: epubController,
        ),
      ),
      body: EpubView(
        controller: epubController,
      ),
    );
  }
}
