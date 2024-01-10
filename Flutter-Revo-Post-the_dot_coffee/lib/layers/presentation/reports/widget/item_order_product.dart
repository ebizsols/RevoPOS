import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';
import 'package:revo_pos/core/utils/media_query.dart';
import 'package:revo_pos/layers/presentation/revo_pos_button.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class ItemOrderProduct extends StatelessWidget {
  final Function() onTap;
  final String? url;
  final String? name;
  final String? total;
  const ItemOrderProduct(
      {Key? key, required this.onTap, this.url, this.name, this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: url!,
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
                Text(
                  name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: colorBlack),
                ),
                Text(
                  "$total",
                  overflow: TextOverflow.clip,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            )),
            const SizedBox(width: 12),
            RevoPosButton(text: "Detail", onPressed: onTap)
          ],
        ),
      ),
    );
  }
}
