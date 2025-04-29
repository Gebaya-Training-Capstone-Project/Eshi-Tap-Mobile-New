import 'package:eshi_tap/features/Restuarant/data/model/meals_model.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';



class RestaurantModel {
  final String id;
  final String restaurantName;
  final String description;
  final String location;
  final List<RestaurantImage> restaurantImages;
  final double latitude;
  final double longitude;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final String userId;
  final List<MealModel>? meals; // Changed to List<MealModel>

  RestaurantModel({
    required this.id,
    required this.restaurantName,
    required this.description,
    required this.location,
    required this.restaurantImages,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.meals,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] as String,
      restaurantName: json['restaurantName'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      restaurantImages: (json['restaurantImages'] as List)
          .map((image) => RestaurantImage(
                secureUrl: image['secure_url'] as String,
                publicId: image['public_id'] as String,
                defaultImage: image['defaultImage'] ?? false,
              ))
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longtiude'] as num).toDouble(), // Note: Typo in API ("longtiude" instead of "longitude")
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      userId: json['userId'] as String,
      meals: (json['meals'] as List?)?.map((meal) => MealModel.fromJson(meal as Map<String, dynamic>)).toList(),
    );
  }
}

extension RestaurantModelX on RestaurantModel {
  Restaurant toEntity() {
    return Restaurant(
      id: id,
      restaurantName: restaurantName,
      description: description,
      location: location,
      restaurantImages: restaurantImages,
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      meals: meals?.map((meal) => meal.toEntity()).toList(),
    );
  }
}