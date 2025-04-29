import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/cart_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/restaurant_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userLocation;
  bool isLocationPermissionGranted = false;
  String greeting = 'Good morning';
  String? selectedCategory;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _setGreetingBasedOnTime();
    _requestLocationPermission();
    _loadCategories();
  }

  void _setGreetingBasedOnTime() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour < 12) {
        greeting = 'Good morning';
      } else if (hour < 17) {
        greeting = 'Good afternoon';
      } else {
        greeting = 'Good evening';
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    var permissionStatus = await Permission.location.status;
    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      permissionStatus = await Permission.location.request();
    }

    if (permissionStatus.isGranted) {
      setState(() {
        isLocationPermissionGranted = true;
      });
      await _fetchUserLocation();
    } else {
      setState(() {
        isLocationPermissionGranted = false;
        userLocation = 'Location unavailable';
      });
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          userLocation = 'Location services disabled';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        userLocation = 'Bole Wollo Sefer';
      });
    } catch (e) {
      setState(() {
        userLocation = 'Location unavailable';
      });
    }
  }

  void _loadCategories() {
    final List<String> allCategories = [
      'spicy',
      'street food',
      'vegetarian',
      'fried',
      'hearty',
      'wraps',
      'slow-cooked',
      'snack',
      'fast food',
      'high-protein',
      'comfort food',
      'gluten-free',
    ];

    categories = [
      {'label': 'All', 'icon': Icons.restaurant_menu},
      ...allCategories.map((category) {
        IconData icon;
        switch (category) {
          case 'spicy':
            icon = Icons.local_fire_department;
            break;
          case 'street food':
            icon = FontAwesomeIcons.cartShopping;
            break;
          case 'vegetarian':
            icon = FontAwesomeIcons.leaf;
            break;
          case 'fried':
            icon = FontAwesomeIcons.oilCan;
            break;
          case 'hearty':
            icon = FontAwesomeIcons.bowlRice;
            break;
          case 'wraps':
            icon = FontAwesomeIcons.breadSlice;
            break;
          case 'slow-cooked':
            icon = Icons.timer;
            break;
          case 'snack':
            icon = FontAwesomeIcons.cookie;
            break;
          case 'fast food':
            icon = FontAwesomeIcons.burger;
            break;
          case 'high-protein':
            icon = FontAwesomeIcons.dumbbell;
            break;
          case 'comfort food':
            icon = FontAwesomeIcons.utensils;
            break;
          case 'gluten-free':
            icon = FontAwesomeIcons.wheatAwnCircleExclamation;
            break;
          default:
            icon = Icons.fastfood;
        }
        return {'label': category, 'icon': icon};
      }).toList(),
    ];
  }

  void _filterMealsByCategory(String? category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Future<void> _onRefresh() async {
    context.read<MealBloc>().add(FetchMeals());
    context.read<RestaurantBloc>().add(FetchRestaurants());
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildMealSkeleton() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColor.placeholder.withOpacity(0.5),
            highlightColor: AppColor.placeholder.withOpacity(0.3),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColor.placeholder.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 100,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 70,
                              height: 12,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 90,
                              height: 12,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColor.placeholder.withOpacity(0.5),
          highlightColor: AppColor.placeholder.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColor.placeholder.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 150,
                              height: 16,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            Container(
                              width: 60,
                              height: 20,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: AppColor.placeholder.withOpacity(0.5),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: AppColor.placeholder.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 50,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                expandedHeight: 120.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColor.placeholder,
                                  child: const Text(
                                    'N',
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$greeting\nWelcome',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColor.primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (isLocationPermissionGranted && userLocation != null)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: AppColor.subTextColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              userLocation!.length > 20
                                                  ? '${userLocation!.substring(0, 20)}...'
                                                  : userLocation!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.subTextColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      GestureDetector(
                                        onTap: _requestLocationPermission,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 18,
                                              color: AppColor.secondoryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Turn on location services',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.subTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primaryColor,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Categories with Horizontal Scrolling
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final label = category['label'] as String;
                            final icon = category['icon'] as IconData;
                            final isSelected = selectedCategory == label;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _buildCategoryButton(
                                context,
                                icon: icon,
                                label: label,
                                isSelected: isSelected,
                                onTap: () => _filterMealsByCategory(label),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Highest Rated Meals (Horizontal Scrolling)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Highest Rated',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<MealBloc, MealState>(
                            builder: (context, state) {
                              if (state is MealLoading) {
                                return _buildMealSkeleton();
                              } else if (state is MealLoaded) {
                                final meals = state.meals
                                    .where((meal) => meal.availability)
                                    .toList()
                                    .where((meal) =>
                                        selectedCategory == null ||
                                        selectedCategory == 'All' ||
                                        (meal.categories != null &&
                                            meal.categories!.contains(selectedCategory)))
                                    .toList()
                                  ..sort((a, b) => (b.ratings?.average ?? 0.0)
                                      .compareTo(a.ratings?.average ?? 0.0));
                                if (meals.isEmpty) {
                                  return const Center(child: Text('No meals available'));
                                }
                                return SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    itemCount: meals.length,
                                    itemBuilder: (context, index) {
                                      final meal = meals[index];
                                      String imageUrl = 'https://picsum.photos/150';
                                      if (meal.images.isNotEmpty) {
                                        final defaultImage = meal.images.firstWhere(
                                          (image) => image.defaultImage,
                                          orElse: () => meal.images.first,
                                        );
                                        imageUrl = defaultImage.secureUrl;
                                        debugPrint('Meal image URL: $imageUrl');
                                      }
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MealDetailsPage(meal: meal),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 150,
                                          margin: const EdgeInsets.only(right: 16.0),
                                          child: Card(
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
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: double.infinity,
                                                    height: 90,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      debugPrint('Meal image load error: $error');
                                                      return const Icon(Icons.error);
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              color: AppColor.secondoryColor,
                                                              size: 14,
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              '${meal.ratings?.average ?? 0.0}',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: AppColor.primaryTextColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          meal.name,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: AppColor.primaryTextColor,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          '${meal.price.toStringAsFixed(0)} ${meal.currency}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: AppColor.subTextColor,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          'Trattoria Gusto',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: AppColor.subTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else if (state is MealError) {
                                return Center(child: Text(state.message));
                              }
                              return const Center(child: Text('No meals found'));
                            },
                          ),
                          const SizedBox(height: 16),

                          // Recommended Restaurants
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<RestaurantBloc, RestaurantState>(
                            builder: (context, state) {
                              if (state is RestaurantLoading) {
                                return _buildRestaurantSkeleton();
                              } else if (state is RestaurantLoaded) {
                                final restaurants = state.restaurants
                                    .where((restaurant) => restaurant.status)
                                    .toList();
                                if (restaurants.isEmpty) {
                                  return const Center(child: Text('No restaurants available'));
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: restaurants.length,
                                  itemBuilder: (context, index) {
                                    final restaurant = restaurants[index];
                                    String imageUrl = 'https://picsum.photos/150';
                                    if (restaurant.restaurantImages.isNotEmpty) {
                                      final defaultImage = restaurant.restaurantImages.firstWhere(
                                        (image) => image.defaultImage,
                                        orElse: () => restaurant.restaurantImages.first,
                                      );
                                      imageUrl = defaultImage.secureUrl;
                                      debugPrint('Restaurant image URL: $imageUrl');
                                    }

                                    double calculateAverageRating(List<Meal>? meals) {
                                      if (meals == null || meals.isEmpty) return 0.0;
                                      double totalRating = 0.0;
                                      int count = 0;
                                      for (var meal in meals) {
                                        final averageRating = meal.ratings?.average ?? 0.0;
                                        if (averageRating > 0) {
                                          totalRating += averageRating;
                                          count++;
                                        }
                                      }
                                      return count > 0 ? (totalRating / count) : 0.0;
                                    }

                                    final averageRating = calculateAverageRating(restaurant.meals);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                              ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: double.infinity,
                                                  height: 150,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    debugPrint('Restaurant image load error: $error');
                                                    return const Icon(Icons.error);
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            restaurant.restaurantName.length > 25
                                                                ? '${restaurant.restaurantName.substring(0, 25)}...'
                                                                : restaurant.restaurantName,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: AppColor.primaryTextColor,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                            vertical: 4.0,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: restaurant.status
                                                                ? Colors.green.withOpacity(0.1)
                                                                : Colors.red.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            restaurant.status ? 'Open' : 'Closed',
                                                            style: TextStyle(
                                                              color: restaurant.status ? Colors.green : Colors.red,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      restaurant.description.length <= 100
                                                          ? restaurant.description
                                                          : '${restaurant.description.substring(0, 100)}...',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColor.subTextColor,
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
                                                              averageRating > 0
                                                                  ? averageRating.toStringAsFixed(1)
                                                                  : 'N/A',
                                                              style:  TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColor.primaryTextColor,
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
                                                              style:  TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColor.primaryTextColor,
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
                                                              '20 min',
                                                              style:  TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: AppColor.primaryTextColor,
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
                                return  Center(child: Text(state.message));
                              }
                              return const Center(child: Text('No restaurants found'));
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.2)
              : AppColor.placeholder.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColor.primaryColor : AppColor.primaryTextColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppColor.primaryColor : AppColor.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}