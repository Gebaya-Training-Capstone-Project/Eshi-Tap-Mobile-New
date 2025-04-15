import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_details_page.dart';
import 'package:eshi_tap/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MealPage extends StatelessWidget {
  const MealPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MealBloc>()..add(FetchMeals()),
      child: Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: const Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),
        //   title: Text(
        //     'Food Category',
        //     style: TextStyle(
        //       color: AppColor.headerTextColor,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        //   actions: [
        //     Stack(
        //       children: [
        //         IconButton(
        //           icon: const Icon(Icons.shopping_cart),
        //           onPressed: () {
        //             // Add cart navigation logic later
        //           },
        //         ),
        //         Positioned(
        //           right: 8,
        //           top: 8,
        //           child: Container(
        //             padding: const EdgeInsets.all(4),
        //             decoration: BoxDecoration(
        //               color: AppColor.primaryColor,
        //               shape: BoxShape.circle,
        //             ),
        //             child: const Text(
        //               '2',
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 12,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: 'Search dishes,',
            //       prefixIcon: const Icon(Icons.search),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(8),
            //         borderSide: BorderSide.none,
            //       ),
            //       filled: true,
            //       fillColor: AppColor.secondoryBackgroundColor,
            //     ),
            //   ),
            // ),
            Expanded(
              child: BlocBuilder<MealBloc, MealState>(
                builder: (context, state) {
                  if (state is MealLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MealLoaded) {
                    final meals = state.meals.where((meal) => meal.availability).toList();
                    if (meals.isEmpty) {
                      return const Center(child: Text('No meals available'));
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
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
                                        style: TextStyle(
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
                          ),
                        );
                      },
                    );
                  } else if (state is MealError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('No meals found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}