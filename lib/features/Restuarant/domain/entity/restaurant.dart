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

  Map<String, dynamic> toJson() {
    return {
      'secure_url': secureUrl,
      'public_id': publicId,
      'defaultImage': defaultImage,
    };
  }

  factory RestaurantImage.fromJson(Map<String, dynamic> json) {
    return RestaurantImage(
      secureUrl: json['secure_url'] as String,
      publicId: json['public_id'] as String,
      defaultImage: json['defaultImage'] as bool? ?? false,
    );
  }
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
  final List<Meal>? meals;

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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantName': restaurantName,
      'description': description,
      'location': location,
      'restaurantImages': restaurantImages.map((image) => image.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'meals': meals?.map((meal) => meal.toJson()).toList(),
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] as String,
      restaurantName: json['restaurantName'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      restaurantImages: (json['restaurantImages'] as List)
          .map((image) => RestaurantImage.fromJson(image as Map<String, dynamic>))
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longtiude'] as num? ?? json['longitude'] as num).toDouble(),
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      userId: json['userId'] as String,
      meals: json['meals'] != null
          ? (json['meals'] as List)
              .map((meal) {
                if (meal is String) {
                  // Handle the case where meals is a list of meal IDs (strings)
                  return Meal(
                    id: meal,
                    name: '',
                    price: 0.0,
                    currency: '',
                    images: [],
                    availability: false,
                  );
                }
                return Meal.fromJson(meal as Map<String, dynamic>);
              })
              .toList()
          : null,
    );
  }
}