import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marquee/marquee.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Variables/var_strings.dart';

class Global {
  static bool updater = false;
  static String? onRoom;
  static late Profile profile;
  static late Strings str;
  static final GlobalKey<NavigatorState> navigator =
      GlobalKey<NavigatorState>();
  static final ImagePicker picker = ImagePicker();
  static void showBar(BuildContext? context, String strings,
      {SnackBarAction? action}) {
    if (context != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings), action: action));
    }
  }

  static const String defaultImageUrl =
      "https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510_960_720.jpg";
  static const String dbLink = "https://pascaid-default-rtdb.firebaseio.com/";
  static Widget defaultPadding(
      {required Widget child,
      double top = 5,
      double left = -1,
      double right = -1,
      double bottom = 0,
      double all = -1,
      double horizontal = 20,
      double vertical = -1}) {
    if (all >= 0) {
      horizontal = all;
      vertical = all;
    }
    if (left < 0) left = horizontal;
    if (right < 0) right = horizontal;
    if (vertical >= 0) {
      top = vertical;
      bottom = vertical;
    }

    return Padding(
        padding:
            EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
        child: child);
  }

  static Color colorDim(BuildContext context) {
    return (Theme.of(context).brightness == Brightness.dark)
        ? const Color.fromRGBO(30, 30, 30, 1)
        : const Color.fromRGBO(225, 225, 225, 1);
  }

  static Size textSize(Text text) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text.data, style: text.style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static Widget marquee(Text text,
      {double? height,
      double offset = 100,
      double scale = 1,
      bool isAppBar = false}) {
    if (isAppBar) {
      offset = Global.appBarMarqueeOffset;
      height = Global.appBarMarqueeHeight;
      scale = Global.appBarFontScale;
    }
    return Builder(builder: (context) {
      Size size = textSize(text);
      return (size.width * scale < MediaQuery.of(context).size.width - offset)
          ? Text(text.data ?? "",
              style: text.style, overflow: TextOverflow.fade, softWrap: false)
          : SizedBox(
              height: height ?? (size.height * scale),
              width: size.width * scale,
              child: Marquee(
                  style: text.style,
                  accelerationDuration: const Duration(seconds: 1),
                  decelerationDuration: const Duration(seconds: 1),
                  blankSpace: 20,
                  fadingEdgeEndFraction: 0.025,
                  fadingEdgeStartFraction: 0.025,
                  showFadingOnlyWhenScrolling: false,
                  pauseAfterRound: const Duration(seconds: 3),
                  startAfter: const Duration(seconds: 3),
                  text: text.data ?? ""));
    });
  }

  static double appBarMarqueeHeight = 100;
  static double appBarFontScale = 1.5;
  static double appBarMarqueeOffset = 100;
  static void alertOnlyOnApp(BuildContext context) => showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Global.str.alert),
          content: Text(Global.str.alertOnlyApp),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(Global.str.ok))
          ],
        );
      });
}
