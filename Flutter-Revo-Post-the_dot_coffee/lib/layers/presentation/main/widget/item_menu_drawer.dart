import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';

class ItemMenuDrawer extends StatelessWidget {
  final dynamic icon;
  final String text;
  final String type;
  final bool isSelected;
  final Function() onTap;
  final Color? color;

  const ItemMenuDrawer(
      {Key? key,
      required this.text,
      required this.isSelected,
      required this.icon,
      required this.onTap,
      required this.type,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.secondary
                : colorWhite),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Align(
                alignment: Alignment.center,
                child: type == 'icon'
                    ? FaIcon(
                        icon,
                        size: 20,
                        color: color ??
                            (isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey),
                      )
                    : ShaderMask(
                        child: Image(
                          image: icon,
                        ),
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: isSelected
                                ? [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor
                                  ]
                                : [Colors.grey, Colors.grey],
                            stops: const [
                              0.0,
                              0.5,
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                      ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: color ??
                        (isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey),
                    fontWeight: FontWeight.bold),
              ),
            )),
            if (isSelected)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color ?? colorBlack,
              ),
          ],
        ),
      ),
    );
  }
}
