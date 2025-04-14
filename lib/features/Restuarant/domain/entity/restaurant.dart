

import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';

class RestaurantImage {
  final String secureUrl;
  final String publicId;
  final bool defaultImage;

  RestaurantImage({
    required this.secureUrl,
    required this.publicId,
    required this.defaultImage,
  });
}

class Restaurant {
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
  final List<Meal>? meals; // New field for meals

  Restaurant({
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
}