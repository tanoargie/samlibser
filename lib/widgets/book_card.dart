import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/widgets.dart' as image_widget;
import 'package:image/image.dart' as image_ui;
import 'dart:typed_data';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.epubBook});

  final EpubBook epubBook;

  getImage(image_ui.Image? img) {
    if (img != null) {
      Uint8List test = Uint8List.fromList(image_ui.encodePng(img));
      return image_widget.Image(
        image: image_widget.MemoryImage(test),
      );
    }
    return const image_widget.Image(
        image: image_widget.NetworkImage(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.all(15),
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            children: [
              getImage(epubBook.CoverImage),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(epubBook.Title ?? ''),
              ),
            ],
          ),
        ));
  }
}
