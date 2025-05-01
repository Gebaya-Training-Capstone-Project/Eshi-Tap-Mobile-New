import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_details_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_list_page.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class OrderTrackerPage extends StatefulWidget {
  final String orderId; // This is the txRef from Chapa or actual order ID

  const OrderTrackerPage({super.key, required this.orderId});

  @override
  State<OrderTrackerPage> createState() => _OrderTrackerPageState();
}

class _OrderTrackerPageState extends State<OrderTrackerPage> {
  String? _orderId;
  Timer? _pollingTimer;
  LatLng _restaurantLocation = const LatLng(9.03, 38.74); // Default: Addis Ababa
  LatLng _userLocation = const LatLng(9.04, 38.75); // Default user location

  @override
  void initState() {
    super.initState();
    if (widget.orderId.startsWith('eshi-tap-tx-')) {
      _createOrder();
    } else {
      _orderId = widget.orderId;
      context.read<OrderBloc>().add(FetchOrderEvent(_orderId!));
    }
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_orderId != null) {
        context.read<OrderBloc>().add(FetchOrderEvent(_orderId!));
      }
    });
  }

  Future<void> _createOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('pending_order');
    if (orderData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order details not found')),
      );
      return;
    }

    final orderDetails = jsonDecode(orderData) as Map<String, dynamic>;
    final customerId = orderDetails['customerId'] as String?;
    final restaurantId = orderDetails['restaurantId'] as String?;
    final cartItems = (orderDetails['cartItems'] as List?)?.cast<Map<String, dynamic>>();
    final totalAmount = orderDetails['totalAmount'] as double?;
    final orderStatus = orderDetails['orderStatus'] as String?;
    final txRef = orderDetails['txRef'] as String?;
    final deliveryAddress = orderDetails['deliveryAddress'] as String?;
    final phoneNumber = orderDetails['phoneNumber'] as String?;

    if (restaurantId == null ||
        customerId == null ||
        cartItems == null ||
        totalAmount == null ||
        orderStatus == null ||
        txRef == null ||
        deliveryAddress == null ||
        phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing required order details')),
      );
      return;
    }

    if (txRef != widget.orderId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction reference mismatch')),
      );
      return;
    }

    context.read<OrderBloc>().add(CreateOrderEvent(
      restaurantId: restaurantId,
      customerId: customerId,
      items: cartItems,
      orderStatus: orderStatus,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      txRef: txRef,
    ));
  }

  Future<void> _cancelOrder(String orderStatus) async {
    if (orderStatus.toLowerCase() == 'delivered') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot cancel a delivered order')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final dio = sl<Dio>(); // Access Dio via GetIt
      const baseUrl = 'https://eshi-tap.vercel.app/api';
      final response = await dio.patch(
        '$baseUrl/order/$_orderId/cancel',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        context.read<OrderBloc>().add(FetchOrderEvent(_orderId!));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
      } else {
        throw Exception('Failed to cancel order: ${response.data['message']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) async {
        if (state is OrderCreated) {
          setState(() {
            _orderId = state.order.id;
            _restaurantLocation = LatLng(
              state.order.restaurant.latitude,
              state.order.restaurant.longitude,
            );
            final deliveryAddress = state.order.deliveryAddress;
            if (deliveryAddress != null && deliveryAddress.startsWith('Location: (')) {
              final coords = deliveryAddress
                  .replaceAll('Location: (', '')
                  .replaceAll(')', '')
                  .split(', ');
              _userLocation = LatLng(
                double.parse(coords[0]),
                double.parse(coords[1]),
              );
            }
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('recent_order_id', _orderId!);
          await prefs.remove('pending_order');
        } else if (state is OrderLoaded) {
          setState(() {
            _orderId = state.order.id;
            _restaurantLocation = LatLng(
              state.order.restaurant.latitude,
              state.order.restaurant.longitude,
            );
            final deliveryAddress = state.order.deliveryAddress;
            if (deliveryAddress != null && deliveryAddress.startsWith('Location: (')) {
              final coords = deliveryAddress
                  .replaceAll('Location: (', '')
                  .replaceAll(')', '')
                  .split(', ');
              _userLocation = LatLng(
                double.parse(coords[0]),
                double.parse(coords[1]),
              );
            }
          });
        }
      },
      builder: (context, state) {
        if (_orderId == null && state is! OrderCreated && state is! OrderLoaded) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Track Order',
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
            body: const Center(
              child: Text(
                'No active orders to track.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          );
        }

        if (state is OrderLoading) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Track Order',
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
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrderError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Track Order',
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.orderId.startsWith('eshi-tap-tx-')) {
                        _createOrder();
                      } else {
                        context.read<OrderBloc>().add(FetchOrderEvent(_orderId!));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final order = (state is OrderCreated)
            ? state.order
            : (state is OrderLoaded)
                ? state.order
                : null;

        if (order == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                'Track Order',
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
            body: const Center(
              child: Text(
                'No active orders to track.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'Track Order',
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      center: _restaurantLocation,
                      zoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _restaurantLocation,
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                              Icons.restaurant,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                          Marker(
                            point: _userLocation,
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_restaurantLocation, _userLocation],
                            strokeWidth: 4.0,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR CURRENT ORDER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  order.orderStatus.toLowerCase() == 'pending' ||
                                          order.orderStatus.toLowerCase() == 'confirmed'
                                      ? Icons.check_circle
                                      : Icons.lock,
                                  color: order.orderStatus.toLowerCase() == 'pending' ||
                                          order.orderStatus.toLowerCase() == 'confirmed'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Order Confirmed',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: order.orderStatus.toLowerCase() == 'preparing'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Preparing',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                Icon(
                                  order.orderStatus.toLowerCase() == 'delivered'
                                      ? Icons.check_circle
                                      : Icons.lock,
                                  color: order.orderStatus.toLowerCase() == 'delivered'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Delivered',
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: order.driverId != null
                                  ? 'https://res.cloudinary.com/du9pkirsy/image/upload/v1744364230/eshi-tap/driver_${order.driverId}.png'
                                  : 'https://via.placeholder.com/150',
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey,
                              ),
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 30,
                                backgroundImage: imageProvider,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Courier: ${order.driverId != null ? 'Assigned' : '[Name Unavailable]'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    const Text('[Rating Unavailable]'),
                                    const SizedBox(width: 16),
                                    const Text('ETA: [ETA Unavailable]'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone, color: Colors.green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Call courier - To be implemented')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.message, color: Colors.green),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Message courier - To be implemented')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsPage(
                                      orderId: _orderId!,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Order Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: order.orderStatus.toLowerCase() != 'delivered' &&
                                      order.orderStatus.toLowerCase() != 'cancelled'
                                  ? () => _cancelOrder(order.orderStatus)
                                  : null,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.green),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cancel Order',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderListPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'View Order History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}