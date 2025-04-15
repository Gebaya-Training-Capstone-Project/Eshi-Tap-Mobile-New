import 'package:eshi_tap/core/configs/theme/color_extensions.dart';

import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/restaurant_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RestaurantPage extends StatelessWidget {
  const RestaurantPage({super.key});

  // Helper method to trim the description
  String trimDescription(String description, int maxLength) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  // Helper method to calculate the average rating of a restaurant based on its meals
  double calculateAverageRating(List<Meal> meals) {
    if (meals.isEmpty) return 0.0;
    double totalRating = 0.0;
    int count = 0;
    for (var meal in meals) {
      final averageRating = (meal.ratings?.average as num?)?.toDouble() ?? 0.0;
      if (averageRating > 0) {
        totalRating += averageRating;
        count++;
      }
    }
    return count > 0 ? (totalRating / count) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RestaurantLoaded) {
          final restaurants = state.restaurants;

          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants available'));
          }

          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              // Handle the default image safely
              String imageUrl = 'https://via.placeholder.com/150'; // Fallback placeholder image
              if (restaurant.restaurantImages.isNotEmpty) {
                final defaultImage = restaurant.restaurantImages.firstWhere(
                  (image) => image.defaultImage,
                  orElse: () => restaurant.restaurantImages.first,
                );
                imageUrl = defaultImage.secureUrl;
              }

              final averageRating = calculateAverageRating(restaurant.meals ?? []);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetailsPage(restaurant: restaurant),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'restaurant-image-${restaurant.id}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.restaurantName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColor.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trimDescription(restaurant.description, 100),
                                style: TextStyle(
                                  color: AppColor.subTextColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: AppColor.secondoryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        averageRating > 0 ? averageRating.toStringAsFixed(1) : 'N/A',
                                        style: TextStyle(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.delivery_dining,
                                        color: AppColor.secondoryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '80 birr', // Placeholder until API provides deliveryFee
                                        style: TextStyle(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: AppColor.secondoryColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '20 min', // Placeholder until API provides estimatedDeliveryTime
                                        style: TextStyle(
                                          color: AppColor.primaryTextColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is RestaurantError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('No restaurants found'));
      },
    );
  }
}