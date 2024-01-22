import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:samlibser/widgets/book_text.dart';

class ReadingScreen extends StatefulWidget {
  ReadingScreen(
      {super.key,
      required this.book,
      required this.updatePositionCallback,
      this.cfi})
      : currentChapter = book.Chapters?.first;

  final EpubBook book;
  late final EpubChapter? currentChapter;
  final String? cfi;
  final Function(String lastCfi) updatePositionCallback;

  @override
  State<StatefulWidget> createState() => _ReadingScreen();
}

class _ReadingScreen extends State<ReadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // String lastCfi = epubController.generateEpubCfi() ?? "";
                  // updatePositionCallback(lastCfi);
                  Navigator.of(context).pop(false);
                }),
            title: RichText(
              text: TextSpan(
                  text: widget.book.Title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            )),
        endDrawer: Drawer(
          child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 6);
              },
              padding: const EdgeInsets.all(8),
              itemCount: widget.book.Chapters?.length ?? 0,
              itemBuilder: (ctx, i) =>
                  Text(widget.book.Chapters?[i].Title ?? '')),
        ),
        body: BookText(
            chapters: widget.book.Content?.Html ?? {},
            styles: widget.book.Content?.Css ?? {}));
  }
}
