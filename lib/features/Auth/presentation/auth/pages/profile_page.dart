import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                  color: AppColor.primaryTextColor, // Updated to AppColor
                ),
              ),
              const SizedBox(height: 16.0),

              // Profile Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor, // Updated to AppColor (was Colors.green[600])
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Stack(
                  children: [
                    // Pizza SVG Background
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: SvgPicture.asset(
                          'assets/profilePizza.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Abebe Abebe',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Kept as white for contrast on primaryColor
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              const Text(
                                '+251 7070707',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white, // Kept as white for contrast
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              const Text(
                                'abefoodmood@gmail.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white, // Kept as white for contrast
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'View activity',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.subTextColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile Picture
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150', // Placeholder image
                          ),
                        ),
                      ],
                    ),
                    // Pen Icon
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white, // Kept as white for contrast
                        ),
                        onPressed: () {
                          // Navigate to Edit Profile page (to be provided later)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit Profile page to be implemented'),
                            ),
                          );
                        },
                      ),
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
                        // Placeholder for logout logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logout functionality to be implemented'),
                          ),
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

  Widget _buildListItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColor.primaryTextColor, // Updated to AppColor (was Colors.black)
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
          color: AppColor.primaryTextColor, // Updated to AppColor (was Colors.black)
        ),
        onTap: onTap,
      ),
    );
  }
}