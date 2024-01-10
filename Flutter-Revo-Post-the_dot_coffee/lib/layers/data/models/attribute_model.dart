import 'package:equatable/equatable.dart';

class Attribute {
  String? id;
  String? name;
  String? label;
  List<Term>? term;
  bool selected = false;
  Term? selectedTerm;

  Attribute(
      {this.id,
      this.name,
      this.label,
      this.term,
      this.selected = false,
      this.selectedTerm});

  Map<String, dynamic> toJson() => {
        "attribute_id": id,
        "attribute_name": name,
        "attribute_label": label,
        "term": term,
        "selected": selected
      };

  factory Attribute.fromJson(Map<String, dynamic> json) {
    var term;
    if (json["term"] != null) {
      term = List.generate(
          json['term'].length, (index) => Term.fromJson(json['term'][index]));
    }

    return Attribute(
        id: json["attribute_id"].toString(),
        name: json["attribute_name"],
        label: json["attribute_label"],
        term: term,
        selected: json["selected"] ?? false);
  }
}

class Term {
  String? termID;
  String? name;
  String? slug;
  String? termGroup;
  String? termTaxonomyID;
  String? taxonomy;
  String? description;
  String? parent;
  int? count;
  String? filter;
  bool selected = false;

  Term(
      {this.termID,
      this.name,
      this.slug,
      this.termGroup,
      this.termTaxonomyID,
      this.taxonomy,
      this.description,
      this.parent,
      this.count,
      this.filter,
      this.selected = false});

  Map<String, dynamic> toJson() => {
        "term_id": termID,
        "name": name,
        "slug": slug,
        "term_group": termGroup,
        "term_taxonomy_id": termTaxonomyID,
        "taxonomy": taxonomy,
        "description": description,
        "parent": parent,
        "count": count,
        "filter": filter
      };

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
        termID: json["term_id"].toString(),
        name: json["name"],
        slug: json["slug"],
        termGroup: json["term_group"].toString(),
        termTaxonomyID: json["term_taxonomy_id"].toString(),
        taxonomy: json["taxonomy"],
        description: json["description"],
        parent: json["parent"].toString(),
        count: json["count"],
        filter: json["filter"] ?? false);
  }
}

class ProductAtributeModel {
  String? taxonomyName;
  bool? variation = true;
  bool? visible = true;
  List<String>? options;

  ProductAtributeModel(
      {this.taxonomyName, this.variation, this.visible, this.options});

  Map toJson() => {
        "taxonomy_name": taxonomyName,
        "variation": variation,
        "visible": visible,
        "options": options
      };

  ProductAtributeModel.fromJson(Map json) {
    taxonomyName = json['taxonomy_name'];
    variation = json['variation'];
    visible = json['visible'];
    options = json['options'];
  }
}
