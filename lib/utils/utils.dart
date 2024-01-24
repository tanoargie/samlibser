import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Map<String, Style> parseStyles(Map<String, EpubTextContentFile>? styles) {
  // yo quiero Map<String, Style>
  Map<String, Style> parsedStyles = {};

  styles?.forEach((key, value) {
    String? filteredContent =
        value.Content?.replaceAll(RegExp(r"(.:hover {)((.|\n)*)(})"), '');
    Map<String, Style> styleFileMap =
        Style.fromCss(filteredContent ?? '', (css, errors) {
      Sentry.captureMessage(errors.join(", ")).then((value) => css);
      return css;
    });
    parsedStyles.addAll(styleFileMap);
  });
  return parsedStyles;
}
