import 'package:html_unescape/html_unescape.dart';

class Unescape {
  static htmlToString(String html) {
    var unescape = HtmlUnescape();
    var text = unescape.convert(html);
    return text;
  }
}