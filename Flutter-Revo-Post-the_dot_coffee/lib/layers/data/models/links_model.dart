import 'package:revo_pos/layers/domain/entities/links.dart';

class LinksModel extends Links {
  final List<SelfModel>? self;
  final List<CollectionModel>? collection;

  LinksModel({
    this.self,
    this.collection,
  });

  factory LinksModel.fromJson(Map<String, dynamic> json) {
    var self;
    if (json['self'] != null) {
      self = List.generate(json['self'].length, (index) =>
          SelfModel.fromJson(json['self'][index]));
    }

    var collection;
    if (json['collection'] != null) {
      collection = List.generate(json['collection'].length, (index) =>
          CollectionModel.fromJson(json['collection'][index]));
    }

    return LinksModel(
      self : self,
      collection : collection,
    );
  }

  Map<String, dynamic> toJson() {
    var self;
    if (this.self != null) {
      self = this.self!.map((v) => v.toJson()).toList();
    }

    var collection;
    if (this.collection != null) {
      collection = this.collection!.map((v) => v.toJson()).toList();
    }

    return {
      'self' : self,
      'collection' : collection,
    };
  }
}

class SelfModel extends Self {
  final String? href;

  SelfModel({
    this.href,
  });

  factory SelfModel.fromJson(Map<String, dynamic> json) {
    return SelfModel(
      href : json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'href' : href,
    };
  }
}

class CollectionModel extends Collection {
  final String? href;

  CollectionModel({
    this.href,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      href : json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'href' : href,
    };
  }
}