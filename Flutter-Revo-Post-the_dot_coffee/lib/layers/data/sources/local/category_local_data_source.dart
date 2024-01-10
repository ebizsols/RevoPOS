import 'dart:convert';

import 'package:revo_pos/layers/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  @override
  Future<List<CategoryModel>> getCategories() async {
    List list = json.decode('[{"title": "Coffee","image": "assets/images/category_dummy_1.png"},{"title": "Juice","image": "assets/images/category_dummy_2.png"},{"title": "Cake","image": "assets/images/category_dummy_3.png"}]');
    return list.map((category) => CategoryModel.fromJson(category)).toList();
  }
}