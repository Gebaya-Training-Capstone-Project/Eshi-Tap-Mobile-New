import 'dart:async';
import 'dart:convert';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:eshi_tap/core/utilis/http_client.dart';
import 'package:eshi_tap/features/Restuarant/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_details_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_list_page.dart';

class OrderTrackerPage extends StatefulWidget {
  final String orderId; // This is the txRef from Chapa or actual order ID

  const OrderTrackerPage({super.key, required this.orderId});

  @override
  State<OrderTrackerPage> createState() => _OrderTrackerPageState();
}

class _OrderTrackerPageState extends State<OrderTrackerPage> {
  bool _isLoading = true;
  String? _orderId; // The actual order ID from the API
  String? _errorMessage;
  Map<String, dynamic>? _orderDetails;
  LatLng _restaurantLocation =
      const LatLng(9.03, 38.74); // Default: Addis Ababa
  LatLng _userLocation = const LatLng(9.04, 38.75); // Default user location
  Timer? _pollingTimer;
  Map<String, dynamic>? _driverDetails;

  @override
  void initState() {
    super.initState();
    if (widget.orderId.startsWith('eshi-tap-tx-')) {
      _createOrder();
    } else {
      _orderId = widget.orderId;
      _fetchOrderDetails();
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
        _fetchOrderDetails();
      }
    });
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) {
        throw Exception('User not authenticated. Please log in again.');
      }

      final client = getHttpClient();
      final response = await client.get(
        Uri.parse('https://eshi-tap.vercel.app/api/order/$_orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final order = (data['data'] as List).first;
        setState(() {
          _restaurantLocation = LatLng(
            order['restaurant']['latitude'] ?? 9.03,
            order['restaurant']['longitude'] ?? 38.74,
          );
          // Extract user location if available
          final deliveryAddress = order['deliveryAddress'] as String?;
          if (deliveryAddress != null &&
              deliveryAddress.startsWith('Location: (')) {
            final coords = deliveryAddress
                .replaceAll('Location: (', '')
                .replaceAll(')', '')
                .split(', ');
            _userLocation = LatLng(
              double.parse(coords[0]),
              double.parse(coords[1]),
            );
          }
          _orderDetails = {
            'orderId': order['_id'],
            'restaurantName': order['restaurant']['restaurantName'],
            'totalAmount': order['totalAmount'],
            'orderStatus': order['orderStatus'],
            'deliveryAddress': deliveryAddress,
            'items': order['items'],
          };
          // Fetch driver details if available
          if (order['driver'] != null) {
            _driverDetails = {
              'name': order['driver']['name'] ?? 'Unknown',
              'rating': order['driver']['rating']?.toString() ?? 'N/A',
              'eta': order['driver']['eta']?.toString() ?? 'N/A',
            };
          } else {
            _driverDetails = null;
          }
        });
      } else {
        throw Exception(
            'Failed to fetch order details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch order details error: $e');
      setState(() {
        _errorMessage = 'Failed to load order details: $e';
      });
    }
  }

  Future<void> _createOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final orderData = prefs.getString('pending_order');
      debugPrint('Retrieved pending_order: $orderData');
      if (orderData == null) {
        throw Exception('Order details not found in SharedPreferences');
      }

      final orderDetails = jsonDecode(orderData) as Map<String, dynamic>;
      debugPrint('Parsed order details: $orderDetails');

      // Validate required fields
      final restaurantId = orderDetails['restaurantId'] as String?;
      final customerId = orderDetails['customerId'] as String?;
      final token = orderDetails['token'] as String?;
      final cartItems =
          (orderDetails['cartItems'] as List?)?.cast<Map<String, dynamic>>();
      final totalAmount = orderDetails['totalAmount'] as double?;
      final txRef = orderDetails['txRef'] as String?;
      final deliveryAddress = orderDetails['deliveryAddress'] as String?;
      final phoneNumber = orderDetails['phoneNumber'] as String?;

      if (restaurantId == null ||
          customerId == null ||
          token == null ||
          cartItems == null ||
          totalAmount == null ||
          txRef == null ||
          deliveryAddress == null ||
          phoneNumber == null) {
        throw Exception('Missing required order details: $orderDetails');
      }

      if (txRef != widget.orderId) {
        throw Exception(
            'Transaction reference mismatch: expected ${widget.orderId}, got $txRef');
      }

      if (deliveryAddress.startsWith('Location: (')) {
        final coords = deliveryAddress
            .replaceAll('Location: (', '')
            .replaceAll(')', '')
            .split(', ');
        _userLocation = LatLng(
          double.parse(coords[0]),
          double.parse(coords[1]),
        );
      }

      final items = cartItems.map((item) {
        return {
          'item': item['item'],
          'quantity': item['quantity'],
          'price': item['price'],
        };
      }).toList();

      final client = getHttpClient();
      final response = await client
          .post(
            Uri.parse('https://eshi-tap.vercel.app/api/order'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'restaurant': restaurantId,
              'customer': customerId,
              'items': items,
              'orderStatus': 'placed',
              'totalAmount': totalAmount,
              'deliveryAddress': deliveryAddress,
              'phoneNumber': phoneNumber,
              'payment': {
                'method': 'chapa',
                'status': 'completed',
                'transactionId': txRef,
                'paymentDate': DateTime.now().toIso8601String(),
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint(
          'Order creation response: ${response.statusCode} ${response.body}');
      final responseData = jsonDecode(response.body);

      // Check for success: either status 201 or status 200 with success message
      if (response.statusCode == 201 ||
          (response.statusCode == 200 &&
              responseData['message'] == 'Order created successfully!')) {
        final order =
            (responseData['data'] as List).first; // Adjust for array response
        setState(() {
          _orderId = order['_id'];
          _restaurantLocation = LatLng(
            order['restaurant']['latitude'] ?? 9.03,
            order['restaurant']['longitude'] ?? 38.74,
          );
          _orderDetails = {
            'orderId': order['_id'],
            'restaurantName':
                order['restaurant']['restaurantName'] ?? 'Unknown Restaurant',
            'totalAmount': order['totalAmount'],
            'orderStatus': order['orderStatus'],
            'deliveryAddress': deliveryAddress,
            'items': order['items'],
          };
          if (order['driver'] != null) {
            _driverDetails = {
              'name': order['driver']['name'] ?? 'Unknown',
              'rating': order['driver']['rating']?.toString() ?? 'N/A',
              'eta': order['driver']['eta']?.toString() ?? 'N/A',
            };
          }
        });

        await prefs.setString('recent_order_id', _orderId!);
        await prefs.remove('pending_order');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again to continue.');
      } else {
        throw Exception(
            'Failed to create order: ${response.statusCode} - ${responseData['error'] ?? response.body}');
      }
    } catch (e) {
      debugPrint('Order creation error: $e');
      setState(() {
        _errorMessage = 'Failed to create order: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    if (_orderDetails == null ||
        _orderDetails!['orderStatus'].toLowerCase() == 'delivered') {
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

      final client = getHttpClient();
      final response = await client.patch(
        Uri.parse('https://eshi-tap.vercel.app/api/order/$_orderId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          _orderDetails!['orderStatus'] = 'cancelled';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled successfully')),
        );
      } else {
        throw Exception(
            'Failed to cancel order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderId == null && _errorMessage == null && !_isLoading) {
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
                        onPressed: widget.orderId.startsWith('eshi-tap-tx-')
                            ? _createOrder
                            : _fetchOrderDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
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
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _orderDetails!['orderStatus']
                                                        .toLowerCase() ==
                                                    'pending' ||
                                                _orderDetails!['orderStatus']
                                                        .toLowerCase() ==
                                                    'confirmed'
                                            ? Icons.check_circle
                                            : Icons.lock,
                                        color: _orderDetails!['orderStatus']
                                                        .toLowerCase() ==
                                                    'pending' ||
                                                _orderDetails!['orderStatus']
                                                        .toLowerCase() ==
                                                    'confirmed'
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Order Confirmed',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
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
                                          color: _orderDetails!['orderStatus']
                                                      .toLowerCase() ==
                                                  'preparing'
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Preparing',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        _orderDetails!['orderStatus']
                                                    .toLowerCase() ==
                                                'delivered'
                                            ? Icons.check_circle
                                            : Icons.lock,
                                        color: _orderDetails!['orderStatus']
                                                    .toLowerCase() ==
                                                'delivered'
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Delivered',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
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
                                  const CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        'https://via.placeholder.com/150'),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Courier: ${_driverDetails?['name'] ?? '[Name Unavailable]'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.green, size: 16),
                                          const SizedBox(width: 4),
                                          Text(_driverDetails?['rating'] ??
                                              '[Rating Unavailable]'),
                                          const SizedBox(width: 16),
                                          Text(
                                              'ETA: ${_driverDetails?['eta'] ?? '[ETA Unavailable]'}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.phone,
                                            color: Colors.green),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Call courier - To be implemented')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.message,
                                            color: Colors.green),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Message courier - To be implemented')),
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
                                          builder: (context) =>
                                              OrderDetailsPage(
                                            orderId: _orderId!,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                    onPressed: _orderDetails!['orderStatus']
                                                    .toLowerCase() !=
                                                'delivered' &&
                                            _orderDetails!['orderStatus']
                                                    .toLowerCase() !=
                                                'cancelled'
                                        ? _cancelOrder
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      side:
                                          const BorderSide(color: Colors.green),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
  }
}
