import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_html/flutter_html.dart';
import '../utils/utils.dart';

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
  int lastVisibleItem = 0;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  void positionListener() {
    lastVisibleItem = itemPositionsListener.itemPositions.value.last.index;
  }

  @override
  void initState() {
    super.initState();
    itemPositionsListener.itemPositions.addListener(positionListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.updatePositionCallback(lastVisibleItem.toString());
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
        body: ScrollablePositionedList.builder(
          initialScrollIndex: int.tryParse(widget.cfi ?? '0') ?? 0,
          itemCount: widget.book.Content?.Html?.length ?? 0,
          itemBuilder: (context, index) => Html(
              data:
                  (widget.book.Content?.Html?.values.elementAt(index).Content ??
                      ''),
              style: parseStyles(widget.book.Content?.Css ?? {})),
          itemScrollController: itemScrollController,
          scrollOffsetController: scrollOffsetController,
          itemPositionsListener: itemPositionsListener,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(positionListener);
  }
}
