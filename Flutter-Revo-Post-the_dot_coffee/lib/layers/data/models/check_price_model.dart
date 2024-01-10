class CheckPriceModel {
  final int? productId, variationId, price;

  CheckPriceModel({this.productId, this.variationId, this.price});

  Map toJson() =>
      {'product_id': productId, 'variation_id': variationId, 'price': price};

  factory CheckPriceModel.fromJson(Map json) {
    return CheckPriceModel(
        productId: json['product_id'],
        variationId: json['variation_id'],
        price: json['price']);
  }
}

class LineItems {
  final int? productId, variationId;

  LineItems({this.productId, this.variationId});

  Map toJson() => {'product_id': productId, 'variation_id': variationId};

  factory LineItems.fromJson(Map json) {
    return LineItems(
        productId: json['product_id'], variationId: json['variation_id']);
  }
}
