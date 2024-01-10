import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:revo_pos/layers/presentation/revo_pos_loading.dart';

class RevoPosImage extends StatelessWidget {
  final String? url;
  final double? width, height;
  const RevoPosImage({Key? key, required this.url, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageWidget = url != null
        ? CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            width: width ?? 100,
            height: height,
            placeholder: (context, url) => const RevoPosLoading(),
            errorWidget: (context, url, error) => const Icon(Icons.image),
          )
        : const Icon(Icons.image, size: 64,);
    return imageWidget;
  }
}
