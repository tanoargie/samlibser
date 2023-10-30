import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/widgets.dart' as image_widget;
import 'package:image/image.dart' as image_ui;
import 'dart:typed_data';

import 'package:samlibser/widgets/reader.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.epubBook});

  final EpubBook epubBook;

  getImage(image_ui.Image? img) {
    if (img != null) {
      Uint8List png = Uint8List.fromList(image_ui.encodePng(img));
      return image_widget.Image(
        image: image_widget.MemoryImage(png),
        alignment: Alignment.centerLeft,
      );
    }
    return const image_widget.Image(
      image: image_widget.NetworkImage(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png'),
      alignment: Alignment.centerLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(15),
            elevation: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: getImage(epubBook.CoverImage),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.all(10),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(epubBook.Title ?? '',
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w900)),
                              Text(
                                epubBook.Author ?? '',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    iconSize: 20.0,
                                    icon: const Icon(Icons.favorite),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    iconSize: 20.0,
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {},
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReadingScreen(book: epubBook))),
                                    child: const Text('Read'),
                                  ),
                                ],
                              )
                            ])),
                  )
                ],
              ),
            )));
  }
}
