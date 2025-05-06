import 'dart:convert';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart' as theme;
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/profile_page.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/presentation/favorites_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/menu_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:eshi_tap/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/common/widgets/tab_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 2; // Start on Nav 3 (HomePage)
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget? selectPageView;
  List<Restaurant> allRestaurants = [];
  List<Meal> allMeals = [];
  List<Map<String, dynamic>> _orders = [];
  String? recentOrderId;

  @override
  void initState() {
    super.initState();
    selectPageView = const HomePage();
    _loadOrders();
    _fetchRecentOrderId();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('orders');
    setState(() {
      _orders = orderData != null ? List<Map<String, dynamic>>.from(jsonDecode(orderData)) : [];
    });
  }

  Future<void> _fetchRecentOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentOrderId = prefs.getString('recent_order_id');
    });
  }

  Future<void> _addOrder(String orderId, String restaurantName, double totalAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final newOrder = {
      'orderId': orderId,
      'restaurantName': restaurantName,
      'totalAmount': totalAmount,
      'orderStatus': 'preparing',
      'createdAt': DateTime.now().toIso8601String(),
    };
    _orders.insert(0, newOrder);
    await prefs.setString('orders', jsonEncode(_orders));
    await prefs.setString('recent_order_id', orderId);
    setState(() {
      selectPageView = _buildOrderTrackerView();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RestaurantBloc>(
          create: (context) => sl<RestaurantBloc>()..add(FetchRestaurants()),
        ),
        BlocProvider<MealBloc>(
          create: (context) => sl<MealBloc>()..add(FetchMeals()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<RestaurantBloc, RestaurantState>(
            listener: (context, state) {
              if (state is RestaurantLoaded) {
                setState(() {
                  allRestaurants = state.restaurants;
                  allMeals = state.restaurants
                      .expand((restaurant) => restaurant.meals ?? [])
                      .toList()
                      .cast<Meal>();
                });
              }
            },
          ),
          BlocListener<MealBloc, MealState>(
            listener: (context, state) {
              if (state is MealLoaded) {
                setState(() {
                  allMeals = state.meals;
                });
              }
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            if (selectPageView == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Scaffold(
              body: PageStorage(bucket: storageBucket, child: selectPageView!),
              backgroundColor: const Color(0xfff5f5f5),
              floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
              floatingActionButton: SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  onPressed: () {
                    if (selctTab != 2) {
                      selctTab = 2;
                      selectPageView = const HomePage();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  shape: const CircleBorder(),
                  backgroundColor: selctTab == 2 ? theme.AppColor.primaryColor : theme.AppColor.placeholder,
                  child: const Icon(Icons.home, color: Colors.white, size: 30),
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                surfaceTintColor: AppColor.backgroundColor,
                shadowColor: Colors.black,
                elevation: 1,
                notchMargin: 12,
                height: 64,
                shape: const CircularNotchedRectangle(),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TabButton(
                        title: "Menu",
                        icon: Icons.restaurant_menu,
                        onTap: () {
                          if (selctTab != 0) {
                            selctTab = 0;
                            selectPageView = const MenuPage();
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        isSelected: selctTab == 0,
                      ),
                      TabButton(
                        title: "Favourite",
                        icon: Icons.favorite,
                        onTap: () {
                          if (selctTab != 1) {
                            selctTab = 1;
                            selectPageView = FavoritesPage(
                              allMeals: allMeals,
                              allRestaurants: allRestaurants,
                            );
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        isSelected: selctTab == 1,
                      ),
                      const SizedBox(width: 40, height: 40),
                      TabButton(
                        title: "Orders",
                        icon: Icons.track_changes,
                        onTap: () {
                          if (selctTab != 3) {
                            selctTab = 3;
                            selectPageView = _buildOrderTrackerView();
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        isSelected: selctTab == 3,
                      ),
                      TabButton(
                        title: "Profile",
                        icon: Icons.person,
                        onTap: () {
                          if (selctTab != 4) {
                            selctTab = 4;
                            selectPageView = ProfilePage();
                          }
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        isSelected: selctTab == 4,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderTrackerView() {
    if (recentOrderId == null || _orders.isEmpty) {
      return const OrderTrackerPage(orderId: 'placeholder', isInitial: true);
    }
    return OrderTrackerPage(orderId: recentOrderId!);
  }
}