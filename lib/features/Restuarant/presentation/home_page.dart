import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Add navigation logic if needed
          },
        ),
        title: Text(
          'Restaurants',
          style: TextStyle(
            color: AppColor.headerTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Add notification logic
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.notificationColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RestaurantLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search restaurants',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColor.secondoryBackgroundColor,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = state.restaurants[index];
                      final defaultImage =
                          restaurant.restaurantImages.firstWhere(
                        (image) => image.defaultImage,
                        orElse: () => restaurant.restaurantImages.first,
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsPage(
                                    restaurant: restaurant),
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
                                  tag:
                                      'restaurant-image-${restaurant.id}', // Unique tag for Hero animation
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      defaultImage.secureUrl,
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        trimDescription(
                                            restaurant.description, 100),
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
                                              const SizedBox(
                                                  width: 2), // Reduced spacing
                                              Text(
                                                '4.7', // Replace with restaurant.rating when API is updated
                                                style: TextStyle(
                                                  color: AppColor
                                                      .primaryTextColor, // Match the orange color
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              width: 12), // Space between pairs
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.delivery_dining,
                                                color: AppColor.secondoryColor,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                  width: 2), // Reduced spacing
                                              Text(
                                                '80 birr', // Replace with restaurant.deliveryFee when API is updated
                                                style: TextStyle(
                                                  color: AppColor
                                                      .primaryTextColor, // Match the orange color
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                              width: 12), // Space between pairs
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: AppColor.secondoryColor,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                  width: 2), // Reduced spacing
                                              Text(
                                                '20 min', // Replace with restaurant.estimatedDeliveryTime when API is updated
                                                style: TextStyle(
                                                  color: AppColor
                                                      .primaryTextColor, // Match the orange color
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
                  ),
                ),
              ],
            );
          } else if (state is RestaurantError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No restaurants found'));
        },
      ),
    );
  }
}
