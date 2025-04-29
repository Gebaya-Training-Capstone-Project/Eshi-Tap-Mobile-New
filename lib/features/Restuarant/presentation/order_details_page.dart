import 'dart:convert';
import 'package:eshi_tap/core/utilis/http_client.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_list_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderDetails;
  String? _errorMessage;
  String? _deliveryAddress; // Store deliveryAddress separately

  @override
  void initState() {
    super.initState();
    _loadDeliveryAddress();
    _fetchOrderDetails();
  }

  // Load deliveryAddress from SharedPreferences if not available in API response
  Future<void> _loadDeliveryAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('pending_order');
    if (orderData != null) {
      final orderDetails = jsonDecode(orderData) as Map<String, dynamic>;
      setState(() {
        _deliveryAddress = orderDetails['deliveryAddress'] as String? ?? 'Not specified';
      });
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final client = getHttpClient(); // Use the custom HTTP client
      final response = await client.get(
        Uri.parse('https://eshi-tap.vercel.app/api/order/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final order = (data['data'] as List).first;
        setState(() {
          _orderDetails = {
            'orderId': order['_id'],
            'restaurantName': order['restaurant']['restaurantName'],
            'totalAmount': order['totalAmount'],
            'orderStatus': order['orderStatus'],
            'deliveryAddress': order['deliveryAddress'], // May be null
            'items': order['items'],
            'createdAt': order['createdAt'],
          };
        });
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again to continue.');
      } else {
        throw Exception('Failed to fetch order details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch order details error: $e');
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
          'Order Details',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => OrderListPage()),
              (route) => false,
            )
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
                        onPressed: _fetchOrderDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${_orderDetails!['orderId']}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Restaurant: ${_orderDetails!['restaurantName']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Amount: ${_orderDetails!['totalAmount']} ETB',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${_orderDetails!['orderStatus']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order Date: ${_orderDetails!['createdAt']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Delivery Address: ${_deliveryAddress ?? _orderDetails!['deliveryAddress'] ?? 'Not specified'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Items:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_orderDetails!['items'] as List).map((item) {
                        // Adjust based on actual item structure
                        final itemName = item['item'] is Map
                            ? item['item']['name'] ?? 'Item (ID: ${item['item']['_id'] ?? 'Unknown'})'
                            : 'Item (ID: ${item['item'] ?? 'Unknown'})';
                        return ListTile(
                          title: Text(itemName),
                          subtitle: Text(
                            'Quantity: ${item['quantity'] ?? 'N/A'} | Price: ${item['price'] ?? 'N/A'} ETB',
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}