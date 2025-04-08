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
      longitude: (json['longtiude'] as num).toDouble(),
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
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
      restaurantImages: restaurantImages, // Now the same type, no conversion needed
      latitude: latitude,
      longitude: longitude,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}