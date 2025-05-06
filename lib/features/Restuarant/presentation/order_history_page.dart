import 'dart:convert';

import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('orders');
    setState(() {
      _orders = orderData != null ? List<Map<String, dynamic>>.from(jsonDecode(orderData)) : [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Order History', style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainTabView()),
            (route) => false,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _orders.isEmpty
              ? const Center(child: Text('No orders found', style: TextStyle(fontSize: 18, color: Colors.black54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Colors.green),
                        title: Text(order['restaurantName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text('Status: ${order['orderStatus']} | Total: ${order['totalAmount']} ETB'),
                        trailing: const Icon(Icons.arrow_forward, color: Colors.green),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OrderDetailsPage(orderId: order['orderId'])),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}