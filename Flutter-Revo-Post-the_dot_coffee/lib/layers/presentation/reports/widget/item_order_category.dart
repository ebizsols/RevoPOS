import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/core/utils/multicurrency_format.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class ItemOrderCategory extends StatelessWidget {
  // final Function() onTap;
  final String? name, item, image, totalSales, id;
  const ItemOrderCategory(
      {Key? key,
      // required this.onTap,
      this.name,
      this.item,
      this.image,
      this.id,
      this.totalSales})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tempName =
        name!.length > 10 ? "${name!.substring(0, 9)}..." : "$name";
    return InkWell(
      // onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const RevoPosLoading(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported_rounded,
                      size: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HtmlWidget(
                    "#$id - " + tempName,
                    textStyle: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(color: colorBlack),
                  ),
                  Text(
                    "$item item",
                    overflow: TextOverflow.clip,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Text(
                MultiCurrency.convert(double.parse(totalSales!), context),
                textAlign: TextAlign.right,
                overflow: TextOverflow.clip,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
