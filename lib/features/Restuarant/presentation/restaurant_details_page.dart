import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  String selectedCategory = 'All';
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteRestaurantIds =
        prefs.getStringList('favorite_restaurants') ?? [];
    setState(() {
      isFavorite = favoriteRestaurantIds.contains(widget.restaurant.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteRestaurantIds =
        prefs.getStringList('favorite_restaurants') ?? [];

    if (isFavorite) {
      favoriteRestaurantIds.remove(widget.restaurant.id);
    } else {
      favoriteRestaurantIds.add(widget.restaurant.id);
    }

    await prefs.setStringList('favorite_restaurants', favoriteRestaurantIds);
    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${widget.restaurant.restaurantName} added to favorites'
              : '${widget.restaurant.restaurantName} removed from favorites',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultImage = widget.restaurant.restaurantImages.firstWhere(
      (image) => image.defaultImage,
      orElse: () => widget.restaurant.restaurantImages.first,
    );

    final categories = <String>['All'] +
        (widget.restaurant.meals
                ?.map((meal) => meal.categories ?? [])
                .expand((category) => category)
                .toSet()
                .toList() as List<String> ??
            []);

    final filteredMeals = selectedCategory == 'All'
        ? widget.restaurant.meals
                ?.where((meal) => meal.availability)
                .toList() ??
            []
        : widget.restaurant.meals
                ?.where((meal) =>
                    meal.availability &&
                    (meal.categories ?? []).contains(selectedCategory))
                .toList() ??
            [];

    final averageDeliveryTime =
        widget.restaurant.meals != null && widget.restaurant.meals!.isNotEmpty
            ? widget.restaurant.meals!
                    .where((meal) => meal.estimatedDeliveryTime != null)
                    .map((meal) => meal.estimatedDeliveryTime!)
                    .fold(0, (sum, time) => sum + time) /
                widget.restaurant.meals!
                    .where((meal) => meal.estimatedDeliveryTime != null)
                    .length
            : 0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'restaurant-image-${widget.restaurant.id}',
                  child: Image.network(
                    defaultImage.secureUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 50),
                    ),
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
                    Text(
                      widget.restaurant.restaurantName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColor.primaryTextColor,
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
                              widget.restaurant.meals != null &&
                                      widget.restaurant.meals!.isNotEmpty
                                  ? (widget.restaurant.meals!
                                              .map((meal) =>
                                                  meal.ratings?.average ?? 0)
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
                              '80 birr',
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
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: SingleChildScrollView(
                        child: Text(
                          widget.restaurant.description,
                          style: TextStyle(
                            color: AppColor.subTextColor,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    Text(
                      '$selectedCategory (${filteredMeals.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (filteredMeals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text('No meals available in this category'),
                      ),
                  ],
                ),
              ),
            ),
            if (filteredMeals.isNotEmpty)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final meal = filteredMeals[index];
                      final defaultImage = meal.images.firstWhere(
                        (image) => image.defaultImage,
                        orElse: () => meal.images.first,
                      );
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MealDetailsPage(meal: meal),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Hero(
                                        tag: 'meal-image-${meal.id}',
                                        child: Image.network(
                                          defaultImage.secureUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child:
                                                  Icon(Icons.fastfood, size: 40),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColor.primaryTextColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${meal.price.toStringAsFixed(0)} ${meal.currency}',
                                        style: TextStyle(
                                          color: AppColor.subTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: AppColor.primaryColor,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            // Add to cart functionality
                                          },
                                        ),
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
                    childCount: filteredMeals.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}