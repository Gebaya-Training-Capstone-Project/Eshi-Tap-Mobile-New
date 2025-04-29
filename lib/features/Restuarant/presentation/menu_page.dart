import 'dart:async';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
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
  bool isFasting = false;
  String searchQuery = '';
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Start on "Meals" tab
    _tabController.addListener(() {
      setState(() {}); // Rebuild to show/hide fasting toggle based on tab
      // Trigger fetch when tab changes
      if (_tabController.index == 0) {
        context.read<RestaurantBloc>().add(FetchRestaurants(searchQuery: searchQuery));
      } else {
        context.read<MealBloc>().add(FetchMeals(
          searchQuery: searchQuery,
          isFasting: isFasting,
        ));
      }
    });
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim();
      });
      // Debounce the search to prevent excessive API calls (matches HomePage behavior)
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_tabController.index == 0) {
          context.read<RestaurantBloc>().add(FetchRestaurants(searchQuery: searchQuery));
        } else {
          context.read<MealBloc>().add(FetchMeals(
            searchQuery: searchQuery,
            isFasting: isFasting,
          ));
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // Fasting Toggle (only visible on Meals tab)
                  if (_tabController.index == 1)
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
                            // Trigger fetch with fasting filter
                            context.read<MealBloc>().add(FetchMeals(
                              searchQuery: searchQuery,
                              isFasting: isFasting,
                            ));
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
                    create: (context) => RestaurantBloc(sl<GetRestaurants>())
                      ..add(FetchRestaurants(searchQuery: searchQuery)),
                    child: const RestaurantPage(),
                  ),
                  // Meal Page
                  BlocProvider(
                    create: (context) => sl<MealBloc>()
                      ..add(FetchMeals(
                        searchQuery: searchQuery,
                        isFasting: isFasting,
                      )),
                    child: const MealPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}