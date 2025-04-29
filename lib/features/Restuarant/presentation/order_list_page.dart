import 'dart:convert';
import 'package:eshi_tap/core/utilis/http_client.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_details_page.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customer_id');
      final token = prefs.getString('auth_token') ?? '';

      if (customerId == null || token.isEmpty) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final client = getHttpClient(); // Use the custom HTTP client
      final response = await client.get(
        Uri.parse('https://eshi-tap.vercel.app/api/order/customer/$customerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch orders response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Handle potential response structure variations
          _orders = (data['data'] as List? ?? []).cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again to continue.');
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch orders error: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? const Center(child: Text('No orders found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          child: ListTile(
                            title: Text('Order #${order['_id'] ?? 'Unknown'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Restaurant: ${order['restaurant']?['restaurantName'] ?? 'Unknown'}',
                                ),
                                Text(
                                  'Total: ${order['totalAmount']?.toString() ?? 'N/A'} ETB',
                                ),
                                Text(
                                  'Status: ${order['orderStatus'] ?? 'Unknown'}',
                                ),
                                Text(
                                  'Date: ${order['createdAt'] ?? 'Unknown'}',
                                ),
                              ],
                            ),
                            onTap: () {
                              if (order['_id'] != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsPage(
                                      orderId: order['_id'],
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid order ID'),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}