import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

Map<String, Style> parseStyles(Map<String, EpubTextContentFile>? styles) {
  // yo quiero Map<String, Style>
  Map<String, Style> parsedStyles = {};

  styles?.forEach((key, value) {
    String? filteredContent =
        value.Content?.replaceAll(RegExp(r"(.:hover {)((.|\n)*)(})"), '');
    Map<String, Style> styleFileMap =
        Style.fromCss(filteredContent ?? '', (css, errors) {
      // await Sentry.captureMessage(errors.join(", "));
      return css;
    });
    parsedStyles.addAll(styleFileMap);
  });
  return parsedStyles;
}

class BookText extends StatelessWidget {
  BookText({
    super.key,
    required this.chapters,
    required this.styles,
  });

  final Map<String, EpubTextContentFile>? chapters;
  final Map<String, EpubTextContentFile>? styles;

  final ItemScrollController _controller = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  void handleNotification() {}

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: chapters?.length ?? 0,
      itemBuilder: (context, index) => Html(
          data: (chapters?.values.elementAt(index).Content ?? ''),
          style: parseStyles(styles)),
      itemScrollController: _controller,
      scrollOffsetController: scrollOffsetController,
      itemPositionsListener: itemPositionsListener,
      scrollOffsetListener: scrollOffsetListener,
    );
  }
}
