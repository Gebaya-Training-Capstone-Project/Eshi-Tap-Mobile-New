import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:flutter/material.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  String selectedCategory = 'All'; // Default category

  @override
  Widget build(BuildContext context) {
    final defaultImage = widget.restaurant.restaurantImages.firstWhere(
      (image) => image.defaultImage,
      orElse: () => widget.restaurant.restaurantImages.first,
    );

    // Extract unique categories from meals
    final categories = <String>['All'] +
        (widget.restaurant.meals
                ?.map((meal) => meal.categories ?? [])
                .expand((category) => category)
                .toSet()
                .toList() as List<String> ??
            []);

    // Filter meals based on selected category
    final filteredMeals = selectedCategory == 'All'
        ? widget.restaurant.meals?.where((meal) => meal.availability).toList() ?? []
        : widget.restaurant.meals
                ?.where((meal) =>
                    meal.availability && (meal.categories ?? []).contains(selectedCategory))
                .toList() ??
            [];

    // Calculate average estimated delivery time from meals
    final averageDeliveryTime = widget.restaurant.meals != null &&
            widget.restaurant.meals!.isNotEmpty
        ? widget.restaurant.meals!
                .where((meal) => meal.estimatedDeliveryTime != null)
                .map((meal) => meal.estimatedDeliveryTime!)
                .fold(0, (sum, time) => sum + time) /
            widget.restaurant.meals!
                .where((meal) => meal.estimatedDeliveryTime != null)
                .length
        : 0;

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
                tag: 'restaurant-image-${widget.restaurant.id}',
                child: Image.network(
                  defaultImage.secureUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
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
                  // Restaurant Name
                  Text(
                    widget.restaurant.restaurantName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rating, Delivery Fee, Estimated Delivery Time
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
                            widget.restaurant.meals != null &&
                                    widget.restaurant.meals!.isNotEmpty
                                ? (widget.restaurant.meals!
                                            .map((meal) => meal.ratings?.average ?? 0)
                                            .reduce((a, b) => a + b) /
                                        widget.restaurant.meals!.length)
                                    .toStringAsFixed(1)
                                : 'N/A',
                            style: TextStyle(
                              color: AppColor.secondoryColor,
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
                            '80 birr', // Hardcoded until backend provides deliveryFee
                            style: TextStyle(
                              color: AppColor.secondoryColor,
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
                            averageDeliveryTime > 0
                                ? '${averageDeliveryTime.round()} min'
                                : 'N/A',
                            style: TextStyle(
                              color: AppColor.secondoryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    widget.restaurant.description.length > 100
                        ? '${widget.restaurant.description.substring(0, 100)}...'
                        : widget.restaurant.description,
                    style: TextStyle(
                      color: AppColor.subTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Category Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                            selectedColor: AppColor.primaryColor,
                            labelStyle: TextStyle(
                              color: selectedCategory == category
                                  ? Colors.white
                                  : AppColor.primaryTextColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Meals Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCategory (${filteredMeals.length})',
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (filteredMeals.isEmpty)
                    const Text('No meals available in this category')
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: filteredMeals.length,
                      itemBuilder: (context, index) {
                        final meal = filteredMeals[index];
                        final defaultImage = meal.images.firstWhere(
                          (image) => image.defaultImage,
                          orElse: () => meal.images.first,
                        );
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MealDetailsPage(meal: meal),
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
                                  tag: 'meal-image-${meal.id}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Image.network(
                                      defaultImage.secureUrl,
                                      width: double.infinity,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.name,
                                        style:  TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColor.primaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${meal.price.toStringAsFixed(0)} ${meal.currency}',
                                        style: TextStyle(
                                          color: AppColor.subTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon:  Icon(
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