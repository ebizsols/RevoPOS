import 'package:equatable/equatable.dart';

class ProductImage extends Equatable {
  final String? title;
  final String? caption;
  final String? url;
  final String? alt;
  final String? src;
  final String? srcset;
  final String? sizes;
  final String? fullSrc;
  final int? fullSrcW;
  final int? fullSrcH;
  final String? galleryThumbnailSrc;
  final int? galleryThumbnailSrcW;
  final int? galleryThumbnailSrcH;
  final String? thumbSrc;
  final int? thumbSrcW;
  final int? thumbSrcH;
  final int? srcW;
  final int? srcH;

  const ProductImage({
    this.title,
    this.caption,
    this.url,
    this.alt,
    this.src,
    this.srcset,
    this.sizes,
    this.fullSrc,
    this.fullSrcW,
    this.fullSrcH,
    this.galleryThumbnailSrc,
    this.galleryThumbnailSrcW,
    this.galleryThumbnailSrcH,
    this.thumbSrc,
    this.thumbSrcW,
    this.thumbSrcH,
    this.srcW,
    this.srcH,
  });

  @override
  List<Object?> get props => [
    title,
    caption,
    url,
    alt,
    src,
    srcset,
    sizes,
    fullSrc,
    fullSrcW,
    fullSrcH,
    galleryThumbnailSrc,
    galleryThumbnailSrcW,
    galleryThumbnailSrcH,
    thumbSrc,
    thumbSrcW,
    thumbSrcH,
    srcW,
    srcH,
  ];
}
