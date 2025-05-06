import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/presentation/restaurant_details_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  final List<Meal> allMeals;
  final List<Restaurant> allRestaurants;

  const FavoritesPage({
    super.key,
    required this.allMeals,
    required this.allRestaurants,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Meal> favoriteMeals = [];
  List<Restaurant> favoriteRestaurants = [];
  List<String> cartItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load favorite meals
      List<String> mealIds = prefs.getStringList('favorite_meals') ?? [];
      favoriteMeals = widget.allMeals.where((meal) => mealIds.contains(meal.id)).toList();

      // Load favorite restaurants
      List<String> restaurantIds = prefs.getStringList('favorite_restaurants') ?? [];
      favoriteRestaurants = widget.allRestaurants.where((restaurant) => restaurantIds.contains(restaurant.id)).toList();
    });
  }

  Future<void> _toggleFavoriteMeal(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mealIds = prefs.getStringList('favorite_meals') ?? [];
    if (mealIds.contains(mealId)) {
      mealIds.remove(mealId);
      setState(() {
        favoriteMeals.removeWhere((meal) => meal.id == mealId);
      });
    } else {
      mealIds.add(mealId);
      setState(() {
        favoriteMeals = widget.allMeals.where((meal) => mealIds.contains(meal.id)).toList();
      });
    }
    await prefs.setStringList('favorite_meals', mealIds);
  }

  Future<void> _toggleFavoriteRestaurant(String restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> restaurantIds = prefs.getStringList('favorite_restaurants') ?? [];
    if (restaurantIds.contains(restaurantId)) {
      restaurantIds.remove(restaurantId);
      setState(() {
        favoriteRestaurants.removeWhere((restaurant) => restaurant.id == restaurantId);
      });
    } else {
      restaurantIds.add(restaurantId);
      setState(() {
        favoriteRestaurants = widget.allRestaurants.where((restaurant) => restaurantIds.contains(restaurant.id)).toList();
      });
    }
    await prefs.setStringList('favorite_restaurants', restaurantIds);
  }

  void _addToCart(String mealName) {
    setState(() {
      cartItems.add(mealName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$mealName added to cart')),
    );
  }

  // Helper method to trim the description
  String _trimDescription(String description, int maxLength) {
    if (description.length <= maxLength) return description;
    return '${description.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Title
              Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // TabBar (Swapped: Restaurants on the left, Meals on the right)
              TabBar(
                controller: _tabController,
                labelColor: AppColor.primaryColor,
                unselectedLabelColor: AppColor.subTextColor,
                indicatorColor: AppColor.primaryColor,
                tabs: const [
                  Tab(text: 'Favorite Restaurants'),
                  Tab(text: 'Favorite Meals'),
                ],
              ),
              const SizedBox(height: 16),

              // TabBarView (Swapped: Restaurants on the left, Meals on the right)
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Favorite Restaurants Tab (Now on the left)
                    favoriteRestaurants.isEmpty
                        ? const Center(child: Text('No favorite restaurants yet'))
                        : ListView.builder(
                            itemCount: favoriteRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = favoriteRestaurants[index];
                              String imageUrl = 'https://via.placeholder.com/50'; // Fallback placeholder
                              if (restaurant.restaurantImages.isNotEmpty) {
                                final defaultImage = restaurant.restaurantImages.firstWhere(
                                  (image) => image.defaultImage,
                                  orElse: () => restaurant.restaurantImages.first,
                                );
                                imageUrl = defaultImage.secureUrl;
                              }
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RestaurantDetailsPage(restaurant: restaurant),
                                      ),
                                    );
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.restaurant, size: 50),
                                    ),
                                  ),
                                  title: Text(
                                    restaurant.restaurantName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _trimDescription(restaurant.description, 40), // Trimmed to 40 characters
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.subTextColor,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () => _toggleFavoriteRestaurant(restaurant.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                    // Favorite Meals Tab (Now on the right)
                    favoriteMeals.isEmpty
                        ? const Center(child: Text('No favorite meals yet'))
                        : ListView.builder(
                            itemCount: favoriteMeals.length,
                            itemBuilder: (context, index) {
                              final meal = favoriteMeals[index];
                              String imageUrl = 'https://via.placeholder.com/50'; // Fallback placeholder
                              if (meal.images.isNotEmpty) {
                                final defaultImage = meal.images.firstWhere(
                                  (image) => image.defaultImage,
                                  orElse: () => meal.images.first,
                                );
                                imageUrl = defaultImage.secureUrl;
                              }
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MealDetailsPage(meal: meal),
                                      ),
                                    );
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.fastfood, size: 50),
                                    ),
                                  ),
                                  title: Text(
                                    meal.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.primaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _trimDescription(meal.description ?? 'No description', 40), // Trimmed to 40 characters
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.subTextColor,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${meal.price.toStringAsFixed(0)} ${meal.currency}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _toggleFavoriteMeal(meal.id),
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _addToCart(meal.name),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.primaryColor,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}