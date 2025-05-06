import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/profile_info_page.dart';
import 'package:eshi_tap/features/Auth/presentation/auth/pages/signin.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // For Transform.rotate


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
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> transactionHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchTransactionHistory();
  }

  Future<void> _fetchProfile() async {
    const url = 'https://eshi-tap.vercel.app/api/user/loggedInUser';
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDY1MjA2ODAsImV4cCI6MTc0OTExMjY4MH0.gLDzE5Z4YlquTtYqjiAkCEAZA5z-0a14GpqQGlOw18U';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Fetch Profile Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body)['data'];
        setState(() {
          name = jsonResponse['username'] ?? 'Abebe Abebe';
          phoneNumber = jsonResponse['phone'] ?? '+251 7070707';
          emailAddress = jsonResponse['email'] ?? 'abefoodmood@gmail.com';
          profileImageUrl = jsonResponse['imageUrl'] ?? 'https://via.placeholder.com/150';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch profile: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
      setState(() {
        _errorMessage = 'Error fetching profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTransactionHistory() async {
    const url = 'https://eshi-tap.vercel.app/api/order/driver/delivered-orders';
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MDlkNjIzYTU1YmJmZGUyYzgxYmE0ZCIsInJvbGUiOiJkcml2ZXIiLCJlbWFpbCI6InRzZWdhd2VsaWFzQGdtYWlsLmNvbSIsImlhdCI6MTc0NjQyMDgxMSwiZXhwIjoxNzQ5MDEyODExfQ.-oXsJoI1pU2uq7xomX9_1YIAv7UbWpfuZwtnxklVTVU';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          transactionHistory = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
      }
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
    }
  }

  void _addToTransactionHistory(Map<String, dynamic> order) {
    setState(() {
      transactionHistory.insert(0, order);
    });
  }

  Future<void> _updateProfile(String newName, String newPhone, String newEmail) async {
    const url = 'https://eshi-tap.vercel.app/api/user/loggedInUser';
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MDlkNjIzYTU1YmJmZGUyYzgxYmE0ZCIsInJvbGUiOiJkcml2ZXIiLCJlbWFpbCI6InRzZWdhd2VsaWFzQGdtYWlsLmNvbSIsImlhdCI6MTc0NjQyMDgxMSwiZXhwIjoxNzQ5MDEyODExfQ.-oXsJoI1pU2uq7xomX9_1YIAv7UbWpfuZwtnxklVTVU';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': newName,
          'phone': newPhone,
          'email': newEmail,
        }),
      );

      debugPrint('Update Profile Response: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          name = newName;
          phoneNumber = newPhone;
          emailAddress = newEmail;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColor.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.statusCode} - ${response.body}'),
            backgroundColor: AppColor.categorySelectedColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: AppColor.categorySelectedColor,
        ),
      );
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColor.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative circles around the main icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.primaryColor,
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: pi / 2, // Rotate the icon to match the design
                          child: Icon(
                            Icons.logout,
                            size: 40,
                            color: AppColor.backgroundColor,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 10,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 10,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Oh No! You Are Leaving...\nAre You Sure?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SigninPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.backgroundColor,
                    foregroundColor: AppColor.primaryColor,
                    side: BorderSide(color: AppColor.primaryColor),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'YES, LOG ME OUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    foregroundColor: AppColor.backgroundColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'NAH! JUST KIDDING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.backgroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColor.primaryColor))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: AppColor.primaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primaryColor,
                              foregroundColor: AppColor.backgroundColor,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.backgroundColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          phoneNumber,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.backgroundColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          emailAddress,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppColor.backgroundColor,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'View activity',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColor.backgroundColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundColor: AppColor.placeholder,
                                        foregroundImage: NetworkImage(profileImageUrl),
                                        onForegroundImageError: (exception, stackTrace) {
                                          debugPrint('Image Load Error: $exception');
                                        },
                                        child: Icon(
                                          Icons.person,
                                          size: 36,
                                          color: AppColor.backgroundColor,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PersonalInformationPage(
                                                name: name,
                                                phoneNumber: phoneNumber,
                                                emailAddress: emailAddress,
                                                profileImageUrl: profileImageUrl,
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            await _updateProfile(
                                              result['name'],
                                              result['phoneNumber'],
                                              result['emailAddress'],
                                            );
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
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColor.backgroundColor,
                                          ),
                                          child: Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: AppColor.primaryColor,
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
                        Expanded(
                          child: ListView(
                            children: [
                              _buildListItem(
                                context,
                                icon: Icons.history,
                                title: 'Order History',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderHistoryPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildListItem(
                                context,
                                icon: Icons.logout,
                                title: 'Logout',
                                onTap: () {
                                  _showLogoutConfirmationDialog(context);
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
      {required IconData icon, required String title, required VoidCallback onTap}) {
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

  void _showTransactionHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transactionHistory.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(
                            color: AppColor.subTextColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: transactionHistory.length,
                        itemBuilder: (context, index) {
                          final transaction = transactionHistory[index];
                          final customer = transaction['customer'] is String
                              ? null
                              : transaction['customer'] as Map<String, dynamic>?;
                          final amount = transaction['totalAmount']?.toString() ?? 'N/A';
                          final date = transaction['updatedAt'] != null
                              ? DateTime.parse(transaction['updatedAt']).toLocal()
                              : null;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.delivery_dining),
                              title: Text(customer?['username'] ?? 'Customer'),
                              subtitle: Text(
                                date != null
                                    ? 'Delivered on ${date.day}/${date.month}/${date.year}'
                                    : 'Delivery date unknown',
                              ),
                              trailing: Text(
                                '$amount ETB',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}