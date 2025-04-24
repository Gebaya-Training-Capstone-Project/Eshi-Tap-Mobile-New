
import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(bottom: 80),
          child: PageView(
            controller: controller,
            onPageChanged: (index) => setState(() => isLastPage = index == 2),
            children: [
              buildPage(
                imageUrl: 'assets/animation/delivery_animation2.json',
                title: 'Welcome to Eshi Tap',
                subtitle: 'Order delicious meals from your favorite restaurants',
                controller: controller,
              ),
              buildPage(
                imageUrl: 'assets/animation/delivery_animation1.json',
                title: 'Fast and Reliable Delivery',
                subtitle: 'Get your food delivered to your doorstep in minutes',
                controller: controller,
              ),
              buildPage(
                imageUrl: 'assets/animation/delivery_animation4.json',
                title: 'Explore a Variety of Cuisines',
                subtitle:
                    'Discover burgers, pizzas, seafood, and more from top restaurants',
                controller: controller,
              ),
            ],
          ),
        ),
      ),
      bottomSheet: isLastPage
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: AppColor.subTextColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // builder: (context) => MainTabView(),
                          builder: (context) => SignupPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: AppColor.subTextColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Widget buildPage({
  required String imageUrl,
  required String title,
  required String subtitle,
  required PageController controller,
}) =>
    Container(
      color: Colors.white, // Set container background to white
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Lottie.asset(imageUrl),
          ),
          const SizedBox(height: 5),
          SmoothPageIndicator(
            controller: controller,
            count: 3,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 16,
              expansionFactor: 1.5,
              activeDotColor: AppColor.primaryColor,
            ),
            onDotClicked: (index) => controller.animateToPage(
              index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: AppColor.subTextColor,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );