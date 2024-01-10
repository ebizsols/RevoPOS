import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';

class ItemNotification extends StatelessWidget {
  final Function() onTap;

  const ItemNotification({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            SizedBox(
              width: RevoPosMediaQuery.getWidth(context) * 0.25,
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)
                  ),
                  child: Image.asset(
                    "assets/images/placeholder_image.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Your Order On-Hold",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: colorBlack
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(text: "Order "),
                          TextSpan(
                            text: "213156654SFF54",
                            style: TextStyle(color: colorDanger)
                          ),
                          const TextSpan(text: " is on-hold, please contact customer"),
                        ],
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          height: 1,
                          fontSize: 12
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FaIcon(
                            FontAwesomeIcons.clock,
                            size: 16,
                          ),
                        ),
                        Text(
                          "13-11-2020 07:58",
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: colorBlack,
                            fontSize: 12
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
