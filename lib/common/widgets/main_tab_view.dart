import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
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
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = BlocProvider(
    create: (context) => RestaurantBloc(sl<GetRestaurants>())..add(FetchRestaurants()),
    child: const RestaurantPage(),
  );

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
              selectPageView = BlocProvider(
                create: (context) => RestaurantBloc(sl<GetRestaurants>())..add(FetchRestaurants()),
                child: const RestaurantPage(),
              );
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
                    selectPageView = const Center(child: Text('Menu Page'));
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 0,
              ),
              TabButton(
                title: "Offer",
                icon: Icons.local_offer,
                onTap: () {
                  if (selctTab != 1) {
                    selctTab = 1;
                    selectPageView = const Center(child: Text('Offer Page'));
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 1,
              ),
              const SizedBox(width: 40, height: 40),
              TabButton(
                title: "Profile",
                icon: Icons.person,
                onTap: () {
                  if (selctTab != 3) {
                    selctTab = 3;
                    selectPageView = Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(LogoutEvent());
                        },
                        child: const Text('Logout'),
                      ),
                    );
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 3,
              ),
              TabButton(
                title: "More",
                icon: Icons.more_horiz,
                onTap: () {
                  if (selctTab != 4) {
                    selctTab = 4;
                    selectPageView = const Center(child: Text('More Page'));
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