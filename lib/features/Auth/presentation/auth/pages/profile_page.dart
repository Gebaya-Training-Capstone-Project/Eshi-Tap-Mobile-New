import 'package:eshi_tap/features/Auth/presentation/auth/pages/profile_info_page.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = 'Abebe Abebe';
  String phoneNumber = '+251 7070707';
  String emailAddress = 'abefoodmood@gmail.com';
  String profileImageUrl = 'https://via.placeholder.com/150';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Header
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16.0),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Pizza SVG positioned left-center
                    Positioned(
                      left: 0,
                      top: 10,
                      bottom: 10,
                      child: Opacity(
                        opacity: 1.0,
                        child: SvgPicture.asset(
                          'assets/profilePizza.svg',
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info (Text)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phoneNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                emailAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'View activity',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile Picture and Edit Icon
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage: NetworkImage(profileImageUrl),
                            ),
                            const SizedBox(height: 32),
                            GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PersonalInformationPage(
                                      name: name,
                                      phoneNumber: phoneNumber,
                                      emailAddress: emailAddress,
                                      profileImageUrl: profileImageUrl,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    name = result['name'];
                                    phoneNumber = result['phoneNumber'];
                                    emailAddress = result['emailAddress'];
                                    profileImageUrl = result['profileImage'];
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // List Items
              Expanded(
                child: ListView(
                  children: [
                    _buildListItem(
                      context,
                      icon: Icons.history,
                      title: 'Order history',
                      onTap: () {},
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Track order',
                      onTap: () {},
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.credit_card,
                      title: 'Transactions',
                      onTap: () {},
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildListItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        // Handle logout action here
                        // For example, navigate to the login page or clear user data
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SigninPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColor.primaryTextColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColor.primaryTextColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColor.primaryTextColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
