import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';

class ItemReportOrder extends StatelessWidget {
  final String text;
  final Color? indicatorColor;
  final bool? isGradient;
  final String? value;
  final bool? firstPart;

  ItemReportOrder(
      {Key? key,
      this.indicatorColor,
      this.isGradient,
      required this.text,
      this.value,
      this.firstPart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        isGradient != null && isGradient! ? Colors.white : colorBlack;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isGradient != null && isGradient!
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFC7B03),
                    Color(0xFFDC133D),
                    Color(0xFFFC7B03),
                    Color(0xFFDC133D),
                  ],
                  begin: Alignment(-1.0, -4.0),
                  end: Alignment(1.0, 4.0),
                  stops: [0.0, 0.33, 0.66, 1.0],
                  tileMode: TileMode.clamp),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: colorDisabled),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: Text(
                    text,
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 12, color: textColor),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              if (indicatorColor != null)
                Container(
                  height: 8,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: indicatorColor,
                  ),
                )
            ],
          ),
          Text(
            firstPart!
                ? MultiCurrency.convert(double.parse(value!), context)
                : value!,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}
