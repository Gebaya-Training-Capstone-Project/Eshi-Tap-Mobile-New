import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/profile_page.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/menu_page.dart'; // Nav 1

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eshi_tap/common/widgets/tab_button.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 0; // Start on Nav 1 (MenuPage)
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const MenuPage(); // Default to Nav 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SigninPage()),
            );
          }
        },
        child: PageStorage(bucket: storageBucket, child: selectPageView),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              selctTab = 2;
              selectPageView = const HomePage(); // Nav 3: Home Page
            }
            if (mounted) {
              setState(() {});
            }
          },
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? AppColor.primaryColor : AppColor.placeholder,
          child: const Icon(Icons.home, color: Colors.white, size: 30), // Nav 3: Home icon
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
                icon: Icons.restaurant_menu, // Menu icon for Nav 1
                onTap: () {
                  if (selctTab != 0) {
                    selctTab = 0;
                    selectPageView = const MenuPage(); // Nav 1: MenuPage
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 0,
              ),
              TabButton(
                title: "Favourite",
                icon: Icons.favorite, // Favorite icon for Nav 2
                onTap: () {
                  if (selctTab != 1) {
                    selctTab = 1;
                    selectPageView = const FavoritesPage(); // Nav 2: Favorites Page
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
                icon: Icons.track_changes, // Icon for Nav 4 (Order Tracker)
                onTap: () {
                  if (selctTab != 3) {
                    selctTab = 3;
                    selectPageView = const OrderTrackerPage(); // Nav 4: Order Tracker Page
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 3,
              ),
              TabButton(
                title: "Profile",
                icon: Icons.person, // Icon for Nav 5 (Profile)
                onTap: () {
                  if (selctTab != 4) {
                    selctTab = 4;
                    selectPageView = ProfilePage(); // Nav 5: Profile Page (placeholder with logout)
                    // selectPageView = Center(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       context.read<AuthBloc>().add(LogoutEvent());
                    //     },
                    //     child: const Text('Logout'),
                    //   ),
                    // ); // Nav 5: Profile Page (placeholder with logout)
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
  }
}

// Placeholder pages for Nav 2, Nav 3, and Nav 4
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favorites Page - To be implemented'));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Home Page - To be designed later'));
  }
}

class OrderTrackerPage extends StatelessWidget {
  const OrderTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Order Tracker Page - To be implemented later'));
  }
}