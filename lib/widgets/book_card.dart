import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/widgets.dart' as image_widget;

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.epubBook});

  final EpubBook epubBook;

  ImageProvider<Object> getImageProvider(img) {
    if (img != null) {
      return MemoryImage(img.getBytes());
    }
    return const NetworkImage(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png');
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
              image_widget.Image(image: getImageProvider(epubBook.CoverImage)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Text(epubBook.Title ?? ''),
              ),
            ],
          ),
        ));
  }
}
