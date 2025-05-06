import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:eshi_tap/common/widgets/main_tab_view.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_details_page.dart';
import 'package:eshi_tap/core/configs/theme/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderTrackerPage extends StatefulWidget {
  final String orderId;
  final bool isInitial;

  const OrderTrackerPage({super.key, required this.orderId, this.isInitial = false});

  @override
  State<OrderTrackerPage> createState() => _OrderTrackerPageState();
}

class _OrderTrackerPageState extends State<OrderTrackerPage> {
  late StreamSubscription<Map<String, dynamic>> _orderUpdatesSubscription;
  Map<String, dynamic>? _orderData;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _simulatedStatus = 'preparing';
  Timer? _statusTimer;
  bool _isReceived = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isInitial) {
      _initializeOrderTracking();
      _loadOrderStatus();
      _simulateStatusProgression();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _initializeOrderTracking() {
    setState(() => _isLoading = true);
    context.read<OrderBloc>().add(FetchOrderEvent(widget.orderId));
    context.read<OrderBloc>().add(StartOrderUpdates(widget.orderId));
    
    _orderUpdatesSubscription = context.read<OrderBloc>().orderUpdates.listen(
      (orderData) {
        if (mounted) {
          setState(() {
            _orderData = orderData;
            _isLoading = false;
            _simulatedStatus = orderData['orderStatus'] ?? _simulatedStatus;
            if (orderData['driver'] != null && _simulatedStatus == 'preparing') {
              _simulatedStatus = 'out-for-delivery';
              _saveOrderStatus();
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = error.toString();
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _loadOrderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatus = prefs.getString('order_${widget.orderId}_status');
    final isReceived = prefs.getBool('order_${widget.orderId}_received') ?? false;
    if (storedStatus != null) {
      setState(() {
        _simulatedStatus = storedStatus;
        _isReceived = isReceived;
      });
    }
  }

  Future<void> _saveOrderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_${widget.orderId}_status', _simulatedStatus);
    await prefs.setBool('order_${widget.orderId}_received', _isReceived);
  }

  void _simulateStatusProgression() {
    if (_isReceived || widget.isInitial) return;
    _statusTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _simulatedStatus == 'preparing' && _orderData?['driver'] == null) {
        setState(() {
          _orderData?['driver'] = {
            'name': 'John Doe',
            'rating': 4.5,
            'phone': '+251912345678',
            'eta': '15 mins',
          };
          _simulatedStatus = 'out-for-delivery';
        });
        _saveOrderStatus();
      }
    });
  }

  void _markAsReceived() {
    setState(() {
      _isReceived = true;
      _simulatedStatus = 'received';
    });
    _saveOrderStatus();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Received!'),
        content: const Text('Enjoy your meal!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
    if (!mounted || widget.isInitial) return;
    try {
      const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDYxMTk2MDAsImV4cCI6MTc0ODcxMTYwMH0.POQyG_yEWzRYzTnru_5FELM7reHdqBqCyxNNpFZwC6A';
      final dio = Dio();
      const baseUrl = 'https://eshi-tap.vercel.app/api';
      final response = await dio.patch(
        '$baseUrl/order/${widget.orderId}/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        context.read<OrderBloc>().add(StopOrderUpdates());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainTabView()),
            (route) => false,
          );
        }
      } else {
        throw Exception('Failed to cancel order: ${response.data['message']}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling order: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!widget.isInitial) {
      _orderUpdatesSubscription.cancel();
      context.read<OrderBloc>().add(StopOrderUpdates());
      _statusTimer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInitial) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('Track Your Order', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info, color: Colors.green, size: 50),
                  SizedBox(height: 16),
                  Text('No active order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Place an order to start tracking!', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return BlocConsumer<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          setState(() {
            _hasError = true;
            _errorMessage = state.message;
            _isLoading = false;
          });
        } else if (state is OrderLoaded) {
          setState(() {
            _orderData = state.order;
            _isLoading = false;
            _simulatedStatus = state.order['orderStatus'] ?? _simulatedStatus;
            if (state.order['driver'] != null && _simulatedStatus == 'preparing') {
              _simulatedStatus = 'out-for-delivery';
              _saveOrderStatus();
            }
          });
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }

        if (_hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Track Order', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainTabView()),
                  (route) => false,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_errorMessage, style: const TextStyle(fontSize: 18, color: Colors.black54)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _hasError = false;
                      });
                      _initializeOrderTracking();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final orderStatus = _simulatedStatus;
        final driver = _orderData?['driver'] as Map<String, dynamic>?;
        final restaurantLocation = _orderData?['restaurant'] != null 
            ? const LatLng(9.03, 38.74)
            : const LatLng(9.03, 38.74);
        final userLocation = LatLng(
          _orderData?['latitude'] ?? 9.022879507722104,
          _orderData?['longitude'] ?? 38.7359659576416,
        );

        return WillPopScope(
          onWillPop: () async {
            context.read<OrderBloc>().add(StopOrderUpdates());
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: const Text('Track Your Order', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  context.read<OrderBloc>().add(StopOrderUpdates());
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainTabView()),
                    (route) => false,
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  onPressed: _cancelOrder,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                    child: FlutterMap(
                      options: MapOptions(center: restaurantLocation, zoom: 13.0),
                      children: [
                        TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
                        MarkerLayer(markers: [
                          Marker(point: restaurantLocation, width: 40, height: 40, builder: (ctx) => const Icon(Icons.restaurant, color: Colors.red, size: 40)),
                          Marker(point: userLocation, width: 40, height: 40, builder: (ctx) => const Icon(Icons.person_pin_circle, color: Colors.green, size: 40)),
                          if (driver != null) Marker(point: userLocation, width: 40, height: 40, builder: (ctx) => const Icon(Icons.delivery_dining, color: Colors.blue, size: 40)),
                        ]),
                        PolylineLayer(polylines: [
                          if (driver != null) Polyline(points: [restaurantLocation, userLocation], strokeWidth: 4.0, color: Colors.green.withOpacity(0.7)),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusStep('Preparing', orderStatus == 'preparing'),
                            _buildStatusStep('Out for Delivery', orderStatus == 'out-for-delivery'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (!_isReceived) ...[
                          const Text('Confirm Delivery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: 12),
                          Slideto(
                            onAccept: _markAsReceived,
                          ),
                          const SizedBox(height: 24),
                        ],
                        const Text('Delivery Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: 'https://via.placeholder.com/150',
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.person, size: 30, color: Colors.grey),
                              imageBuilder: (context, imageProvider) => CircleAvatar(radius: 30, backgroundImage: imageProvider),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driver != null ? 'Courier: ${driver['name'] ?? 'Unknown'}' : 'Awaiting driver...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(driver?['rating']?.toString() ?? '0.0', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                      ]),
                                      Text(driver != null ? 'ETA: ${driver['eta'] ?? 'N/A'}' : 'N/A', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                    ],
                                  ),
                                  if (driver != null && driver['phone'] != null)
                                    Padding(padding: const EdgeInsets.only(top: 4), child: Text('Phone: ${driver['phone']}', style: const TextStyle(fontSize: 14, color: Colors.black54))),
                                ],
                              ),
                            ),
                            if (driver != null && driver['phone'] != null)
                              Row(children: [
                                IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Calling ${driver['phone']}')))),
                                IconButton(icon: const Icon(Icons.message, color: Colors.green), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message courier - To be implemented')))),
                              ]),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderDetailsPage(orderId: widget.orderId)),
                                ).then((_) {
                                  setState(() {});
                                  _initializeOrderTracking();
                                }),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Order Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: !_isReceived ? _cancelOrder : null,
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                child: const Text('Cancel Order', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusStep(String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey.shade300,
            ),
            child: Icon(isActive ? Icons.check : Icons.circle, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isActive ? Colors.black : Colors.black54, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class Slideto extends StatefulWidget {
  final VoidCallback? onSlide;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const Slideto({
    super.key,
    this.onSlide,
    this.onAccept,
    this.onCancel,
  });

  @override
  _SlidetoState createState() => _SlidetoState();
}

class _SlidetoState extends State<Slideto> {
  double _dragPosition = 0.0;
  double _maxDrag = 0.0; // Will be calculated dynamically
  String _label = 'Slide to Confirm Received';
  bool _accepted = false;
  final double _sliderWidth = 56.0; // Width of the draggable circle
  final GlobalKey _containerKey = GlobalKey(); // Key to get container size

  @override
  void initState() {
    super.initState();
    // Calculate _maxDrag after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMaxDrag();
    });
  }

  void _calculateMaxDrag() {
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final containerWidth = renderBox.size.width;
      setState(() {
        _maxDrag =
            containerWidth - _sliderWidth; // Full width minus slider width
      });
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_accepted) return;

    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, _maxDrag);

      if (_dragPosition < _maxDrag) {
        _label = 'Slide to Confirm Received';
        widget.onSlide?.call();
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragPosition >= _maxDrag) {
      setState(() {
        _label = 'Confirmed!';
        _accepted = true;
      });
      widget.onAccept?.call();
    } else {
      setState(() {
        _dragPosition = 0.0;
        _label = 'Slide to Confirm Received';
      });
      widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      height: 56,
      decoration: BoxDecoration(
        color: _accepted
            ? AppColor.notificationColor.withOpacity(0.2)
            : AppColor.secondoryBackgroundColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _accepted
              ? AppColor.notificationColor
              : AppColor.subTextColor.withOpacity(0.2),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: _accepted ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: AppColor.notificationColor),
                const SizedBox(width: 8),
                Text(
                  _label,
                  style: TextStyle(
                    color: AppColor.notificationColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: _accepted ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: Text(
                _label,
                style: TextStyle(
                  color: AppColor.subTextColor2,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                width: _sliderWidth,
                height: 56,
                decoration: BoxDecoration(
                  color: _accepted
                      ? AppColor.notificationColor
                      : AppColor.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _accepted ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}