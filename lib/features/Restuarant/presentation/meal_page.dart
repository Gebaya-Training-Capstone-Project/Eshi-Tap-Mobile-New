import 'dart:convert';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPage extends StatelessWidget {
  const MealPage({super.key});

  Future<void> _addToCart(BuildContext context, CartItem cartItem) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson = prefs.getStringList('cart_items') ?? [];

    cartItemsJson.add(jsonEncode(cartItem.toJson()));
    await prefs.setStringList('cart_items', cartItemsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cartItem.meal.name} added to cart'),
      ),
    );
  }

  Widget _buildMealSkeleton(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Adjusted to give more height
      ),
      itemCount: 4, // Show 4 skeleton items to simulate loading
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColor.placeholder.withOpacity(0.5),
          highlightColor: AppColor.placeholder.withOpacity(0.3),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 14,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 50,
                              height: 12,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.placeholder.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MealBloc, MealState>(
              builder: (context, state) {
                if (state is MealLoading) {
                  return _buildMealSkeleton(context);
                } else if (state is MealLoaded) {
                  final meals = state.meals.where((meal) => meal.availability).toList();
                  if (meals.isEmpty) {
                    return const Center(child: Text('No meals available'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65, // Adjusted to give more height
                    ),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      final defaultImage = meal.images.isNotEmpty
                          ? meal.images.firstWhere(
                              (image) => image.defaultImage,
                              orElse: () => meal.images.first,
                            )
                          : null;
                      final imageUrl = defaultImage?.secureUrl ?? '';

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
                                  child: imageUrl.isEmpty
                                      ? Image.asset(
                                          'assets/food_placeholder.png',
                                          width: double.infinity,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/food_placeholder.png',
                                            width: double.infinity,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              meal.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColor.primaryTextColor,
                                              ),
                                              maxLines: 1,
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
                                            if (meal.isFasting != null)
                                              Text(
                                                meal.isFasting! ? 'Fasting Friendly' : 'Non-Fasting',
                                                style: TextStyle(
                                                  color: meal.isFasting! ? Colors.green : Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: AppColor.primaryColor,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            final cartItem = CartItem(
                                              meal: meal,
                                              quantity: 1, // Default quantity
                                              selectedAddOns: [], // No add-ons selected here
                                              addOnQuantities: [], // No add-on quantities
                                            );
                                            _addToCart(context, cartItem);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is MealError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<MealBloc>().add(FetchMeals(
                              searchQuery: '',
                              isFasting: false,
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('No meals found'));
              },
            ),
          ),
        ],
      ),
    );
  }
}