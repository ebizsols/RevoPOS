import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosDialog extends StatelessWidget {
  final IconData? titleIcon;
  final Color? primaryColor;
  final String title;
  final String content;
  final List<RevoPosDialogAction> actions;

  const RevoPosDialog({Key? key, required this.title, required this.content, this.titleIcon, this.primaryColor, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      actionsAlignment: MainAxisAlignment.center,
      title: Row(
        children: [
          if (titleIcon != null) Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              titleIcon,
              color: primaryColor ?? Theme.of(context).primaryColor,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headline6!.copyWith(
              color: primaryColor ?? Theme.of(context).primaryColor,
            ),
          )
        ],
      ),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      actions: actions.map((e) => TextButton(
        onPressed: e.onPressed,
        child: Text(
          e.text,
          style: Theme.of(context).textTheme.headline6!.copyWith(
            color: actions.indexOf(e) == actions.length - 1
              ? primaryColor ?? Theme.of(context).primaryColor
              : colorDisabled
          ),
        )
      )).toList(),
    );
  }
}

class RevoPosDialogAction {
  final String text;
  final Function() onPressed;

  RevoPosDialogAction({required this.text, required this.onPressed});
}
