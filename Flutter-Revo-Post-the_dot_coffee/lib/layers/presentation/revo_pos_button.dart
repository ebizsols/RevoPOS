import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosButton extends StatelessWidget {
  final String? text;
  final Widget? icon;
  final Function() onPressed;
  final Color? color;
  final Color? textColor;
  final double? elevation;
  final double? radius;
  final double? fontSize;
  final EdgeInsets? padding;

  const RevoPosButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.color,
      this.textColor,
      this.icon,
      this.elevation,
      this.radius = 32,
      this.fontSize = 14,
      this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 20)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon!,
            Text(text!,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: textColor ?? colorWhite, fontSize: fontSize!))
          ],
        ),
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(padding!),
            elevation: MaterialStateProperty.all<double>(elevation ?? 4),
            backgroundColor: MaterialStateProperty.all<Color>(
                color ?? Theme.of(context).primaryColor),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius!),
            ))),
        onPressed: onPressed);
  }
}
