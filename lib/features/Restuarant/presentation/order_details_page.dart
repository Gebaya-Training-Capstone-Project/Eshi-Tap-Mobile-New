import 'dart:convert';

import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('orders');
    if (orderData != null) {
      final orders = List<Map<String, dynamic>>.from(jsonDecode(orderData));
      final order = orders.firstWhere((o) => o['orderId'] == widget.orderId, orElse: () => {});
      if (order.isNotEmpty) {
        setState(() {
          _orderDetails = order;
          _isLoading = false;
        });
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_orderDetails?['orderStatus'] != 'received') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderTrackerPage(orderId: widget.orderId)),
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Order Details', style: TextStyle(color: Colors.white, fontSize: 20)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_orderDetails?['orderStatus'] != 'received') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderTrackerPage(orderId: widget.orderId)),
                );
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainTabView()),
                  (route) => false,
                );
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white),
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainTabView()),
                (route) => false,
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : _orderDetails == null
                ? const Center(child: Text('Order not found', style: TextStyle(fontSize: 18, color: Colors.black54)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #${_orderDetails!['orderId']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Restaurant: ${_orderDetails!['restaurantName']}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Total: ${_orderDetails!['totalAmount']} ETB', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Status: ${_orderDetails!['orderStatus']}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Date: ${_orderDetails!['createdAt']}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}