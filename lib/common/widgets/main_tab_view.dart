import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/profile_page.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/presentation/favorites_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/menu_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/common/widgets/tab_button.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize selectPageView to HomePage immediately
    selectPageView = const HomePage();
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
      // child: BlocListener<AuthBloc, AuthState>(
      //   listener: (context, state) {
      //     if (state is AuthUnauthenticated) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const SigninPage()),
      //       );
      //     }
      //   },
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
                    // No need to set selectPageView here since it's already set to HomePage
                  });
                }
              },
            ),
            BlocListener<MealBloc, MealState>(
              listener: (context, state) {
                if (state is MealLoaded) {
                  setState(() {
                    allMeals = state.meals;
                    // No need to set selectPageView here since it's already set to HomePage
                  });
                }
              },
            ),
          ],
          child: Builder(
            builder: (context) {
              // Show a loading indicator until data is fetched
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
                    backgroundColor: selctTab == 2 ? AppColor.primaryColor : AppColor.placeholder,
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
                          title: "Order Tracker",
                          icon: Icons.track_changes,
                          onTap: () {
                            if (selctTab != 3) {
                              selctTab = 3;
                              selectPageView = const OrderTrackerPage();
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
}

class OrderTrackerPage extends StatelessWidget {
  const OrderTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Order Tracker Page - To be implemented later'));
  }
}