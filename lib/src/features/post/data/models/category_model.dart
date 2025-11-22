

import 'package:blog_application/src/features/post/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryId,
    required super.categoryName,
    required super.categoryDescription,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        categoryDescription: json["categoryDescription"],
      );

  Map<String, dynamic> toJson() {
    return {
      "categoryId": categoryId,
      "categoryName": categoryName,
      "categoryDescription": categoryDescription,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryDescription: entity.categoryDescription,
    );
  }
}
