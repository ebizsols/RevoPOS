import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';

class ItemImagePicker extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;

  const ItemImagePicker({Key? key, required this.title, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            FaIcon(
              icon,
              color: colorBlack,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline6!.copyWith(
                  color: colorBlack
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
