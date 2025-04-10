

import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';

class MealModel {
  final String id;
  final String name;
  final String? category;
  final double price;
  final String currency;
  final List<MealImage> images;
  final bool availability;
  final String? description;
  final Ratings? ratings;
  final int? preparationTime;
  final int? calories;
  final String? spiceLevel;
  final List<AddOn>? addons;
  final List<Ingredient>? ingredients;
  final double? deliveryFee;
  final bool? isFavorited;

  MealModel({
    required this.id,
    required this.name,
    this.category,
    required this.price,
    required this.currency,
    required this.images,
    required this.availability,
    this.description,
    this.ratings,
    this.preparationTime,
    this.calories,
    this.spiceLevel,
    this.addons,
    this.ingredients,
    this.deliveryFee,
    this.isFavorited,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?, // New field
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      images: (json['images'] as List)
          .map((image) => MealImage(
                secureUrl: image['secure_url'] as String,
                publicId: image['public_id'] as String,
                defaultImage: image['defaultImage'] ?? false,
              ))
          .toList(),
      availability: json['availability'] as bool,
      description: json['description'] as String?,
      ratings: json['ratings'] != null
          ? Ratings(
              average: (json['ratings']['average'] as num).toDouble(),
              count: json['ratings']['count'] as int,
            )
          : null,
      preparationTime: json['preparationTime'] as int?,
      calories: json['calories'] as int?,
      spiceLevel: json['spiceLevel'] as String?,
      addons: (json['addons'] as List?)?.map((addon) => AddOn(
            name: addon['name'] as String,
            price: (addon['price'] as num).toDouble(),
            isRequired: addon['isRequired'] as bool?,
            image: addon['image'] as String?, // New field
          )).toList(),
      ingredients: (json['ingredients'] as List?)?.map((ingredient) {
        if (ingredient is String) {
          return Ingredient(name: ingredient);
        }
        return Ingredient(
          name: ingredient['name'] as String,
          icon: ingredient['icon'] as String?, // New field
        );
      }).toList(),
      deliveryFee: json['deliveryFee'] != null
          ? (json['deliveryFee'] as num).toDouble()
          : null, // New field
      isFavorited: json['isFavorited'] as bool?, // New field
    );
  }
}

extension MealModelX on MealModel {
  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      category: category,
      price: price,
      currency: currency,
      images: images,
      availability: availability,
      description: description,
      ratings: ratings,
      preparationTime: preparationTime,
      calories: calories,
      spiceLevel: spiceLevel,
      addons: addons,
      ingredients: ingredients,
      deliveryFee: deliveryFee,
      isFavorited: isFavorited,
    );
  }
}