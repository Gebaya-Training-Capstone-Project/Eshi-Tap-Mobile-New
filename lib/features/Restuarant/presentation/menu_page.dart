import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/meal_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/restaurant_page.dart';
import 'package:eshi_tap/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFasting = false; // Add state for the toggle

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Start on "Items" tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Fasting Toggle
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: AppColor.secondoryBackgroundColor,
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Fasting Toggle
                  Row(
                    children: [
                      Text(
                        'Fasting',
                        style: TextStyle(
                          color: AppColor.subTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Switch(
                        value: isFasting,
                        onChanged: (value) {
                          setState(() {
                            isFasting = value;
                          });
                        },
                        activeColor: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Restaurants'),
                    Tab(text: 'Meals'),
                  ],
                ),
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Restaurant Page
                  BlocProvider(
                    create: (context) => RestaurantBloc(sl<GetRestaurants>())..add(FetchRestaurants()),
                    child: const RestaurantPage(),
                  ),
                  // Meal Page
                  const MealPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}