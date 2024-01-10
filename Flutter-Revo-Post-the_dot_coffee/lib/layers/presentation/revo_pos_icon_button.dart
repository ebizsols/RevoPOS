import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosIconButton extends StatelessWidget {
  final IconData icon;
  final Function() onPressed;
  final Color? color;

  const RevoPosIconButton({Key? key, required this.icon, required this.onPressed, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(12))
        ),
        child: Icon(
          icon,
          size: 16,
          color: colorWhite,
        ),
      ),
    );
  }
}
