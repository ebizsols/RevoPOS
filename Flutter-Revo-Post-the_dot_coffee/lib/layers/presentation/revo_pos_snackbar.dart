import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosSnackbar{
  final String text;
  final BuildContext context;

  const RevoPosSnackbar({Key? key, required this.text, required this.context});

  showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
            color: colorWhite,
            fontSize: 12
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
      )
    );
  }
}
