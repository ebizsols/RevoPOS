import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';

class ItemFilterDate extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Function() onTap;

  const ItemFilterDate({Key? key, required this.isSelected, required this.onTap, required this.title, this.subtitle, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = isSelected ? Theme.of(context).primaryColor : colorBlack;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            FaIcon(
              icon,
              color: color,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: color
                    ),
                  ),
                  if (subtitle != null) Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: color
                    ),
                  ),
                ],
              )
            ),

            if (isSelected) FaIcon(
              FontAwesomeIcons.check,
              color: color
            )
          ],
        ),
      ),
    );
  }
}
