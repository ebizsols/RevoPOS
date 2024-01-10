import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosChip extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isSelected;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final Function() onTap;

  const RevoPosChip({Key? key, required this.text, required this.isEnabled, required this.isSelected, required this.onTap, this.leftIcon, this.rightIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    if (!isEnabled) {
      color = colorDisabled;
    } else if (isSelected) {
      color = Theme.of(context).primaryColor;
    } else {
      color = colorWhite;
    }

    return Card(
      elevation: !isEnabled || isSelected ? 0 : 2,
      color: color,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leftIcon != null) Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  leftIcon,
                  size: 16,
                  color: isSelected ? colorWhite : colorBlack
                ),
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: isSelected ? colorWhite : colorBlack
                ),
              ),
              if (rightIcon != null) Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  rightIcon,
                  size: 16,
                  color: isSelected ? colorWhite : colorBlack
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
