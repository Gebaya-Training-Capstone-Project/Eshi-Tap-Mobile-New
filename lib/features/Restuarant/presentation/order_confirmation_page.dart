import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;
  final String deliveryAddress;

  const OrderConfirmationPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.deliveryAddress,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _navigateToTracker();
  }

  void _navigateToTracker() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isNavigating) {
        setState(() => _isNavigating = true);
        Navigator.pushReplacementNamed(
          context,
          '/order_tracker',
          arguments: {'orderId': widget.orderId},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 70),
                ),
                Positioned(
                    top: 0,
                    left: 40,
                    child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle))),
                Positioned(
                    top: 20,
                    left: 0,
                    child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle))),
                Positioned(
                    bottom: 20,
                    right: 0,
                    child: Container(
                        width: 15,
                        height: 15,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle))),
                Positioned(
                    bottom: 0,
                    right: 40,
                    child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle))),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Confirmed!',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    'Total: ${widget.totalAmount.toStringAsFixed(2)} ETB',
                    style: TextStyle(
                        fontSize: 18, color: AppColor.primaryTextColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Delivery to: ${widget.deliveryAddress}',
                    style:
                        TextStyle(fontSize: 16, color: AppColor.subTextColor2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!_isNavigating)
                    const CircularProgressIndicator(color: Colors.green),
                  if (_isNavigating)
                    const Text(
                      'Redirecting to tracker...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}