import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:flutter/material.dart';

class RestaurantDetailsPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  // Helper method to trim the description
  String trimDescription(String description, int maxLength) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = restaurant.restaurantImages.firstWhere(
      (image) => image.defaultImage,
      orElse: () => restaurant.restaurantImages.first,
    );

    // Mock categories and menu items to match the screenshot
    final categories = ['Burger', 'Sandwich', 'Pizza', 'Sandwich'];
    final menuItems = [
      {
        'name': 'Burger Spicy',
        'price': 320,
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Burgers Spicy',
        'price': 320,
        'image': 'https://via.placeholder.com/150'
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {
                  // Add favorite functionality later
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag:
                    'restaurant-image-${restaurant.id}', // Match the tag from RestaurantPage
                child: Image.network(
                  defaultImage.secureUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColor.secondoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2), // Reduced spacing
                          Text(
                            '4.7', // Replace with restaurant.rating when API is updated
                            style: TextStyle(
                              color: AppColor
                                  .secondoryColor, // Match the orange color
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12), // Space between pairs
                      Row(
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            color: AppColor.secondoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2), // Reduced spacing
                          Text(
                            '80 birr', // Replace with restaurant.deliveryFee when API is updated
                            style: TextStyle(
                              color: AppColor
                                  .secondoryColor, // Match the orange color
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12), // Space between pairs
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColor.secondoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 2), // Reduced spacing
                          Text(
                            '20 min', // Replace with restaurant.estimatedDeliveryTime when API is updated
                            style: TextStyle(
                              color: AppColor
                                  .secondoryColor, // Match the orange color
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.restaurantName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trimDescription(restaurant.description, 100),
                    style: TextStyle(
                      color: AppColor.subTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(category),
                            backgroundColor: category == 'Burger'
                                ? AppColor.primaryColor
                                : Colors.grey[200],
                            labelStyle: TextStyle(
                              color: category == 'Burger'
                                  ? Colors.white
                                  : AppColor.primaryTextColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Burger (10)', // Hardcoded for now
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColor.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          1.0, // Adjusted to make cards more compact
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/burger.png',
                                fit: BoxFit.cover,
                                height: 100,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColor.primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['price']} Birr',
                                    style: TextStyle(
                                      color: AppColor.subTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: AppColor.primaryColor,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        // Add to cart functionality later
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
