import 'dart:io';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_bloc.dart';
import 'package:eshi_tap/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/injection_container.dart' as di;
import 'package:eshi_tap/features/Restuarant/presentation/address_selection_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_confirmation_page.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
        ),
        BlocProvider<RestaurantBloc>(
          create: (_) => di.sl<RestaurantBloc>(),
        ),
        BlocProvider<MealBloc>(
          create: (_) => di.sl<MealBloc>(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc(dio: di.sl<Dio>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          if (settings.name == '/address_selection') {
            final args = settings.arguments as Map<String, dynamic>?;
            debugPrint('Navigation arguments to AddressSelectionPage: $args');
            double totalAmount = 0.0;
            if (args != null && args['totalAmount'] != null) {
              final totalAmountValue = args['totalAmount'];
              debugPrint('totalAmount type: ${totalAmountValue.runtimeType}, value: $totalAmountValue');
              if (totalAmountValue is double) {
                totalAmount = totalAmountValue;
              } else if (totalAmountValue is String) {
                totalAmount = double.tryParse(totalAmountValue) ?? 0.0;
              } else if (totalAmountValue is Map && totalAmountValue.containsKey('value')) {
                totalAmount = double.tryParse(totalAmountValue['value']?.toString() ?? '0.0') ?? 0.0;
              } else {
                debugPrint('Unexpected totalAmount type: ${totalAmountValue.runtimeType}');
              }
            } else {
              debugPrint('totalAmount is null or missing in arguments');
            }
            final paymentResult = args?['paymentResult'] as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => AddressSelectionPage(
                totalAmount: totalAmount,
                cartItems: args?['cartItems'] ?? [],
                restaurantId: args?['restaurantId'] ?? '681322cb7a5591e3a40ee78d',
                onPlaceOrder: args?['onPlaceOrder'] ??
                    (String address, String reference) {
                      debugPrint('Order placed at $address with ref $reference');
                    },
              ),
              settings: RouteSettings(arguments: {
                'totalAmount': totalAmount,
                'paymentResult': paymentResult,
              }),
            );
          } else if (settings.name == '/order_confirmation') {
            final args = settings.arguments as Map<String, dynamic>?;
            debugPrint('Navigation arguments to OrderConfirmationPage: $args');
            final chapaTxRef = args?['transactionReference']?.toString() ?? 'unknown_tx_ref';
            return MaterialPageRoute(
              builder: (context) => OrderConfirmationLoadingPage(chapaTxRef: chapaTxRef),
            );
          } else if (settings.name == '/order_tracker') {
            final args = settings.arguments as Map<String, dynamic>?;
            final orderId = args?['orderId'] as String? ?? 'unknown_order_id';
            return MaterialPageRoute(
              builder: (context) => OrderTrackerPage(orderId: orderId),
            );
          }
          return null;
        },
      ),
    );
  }
}

class OrderConfirmationLoadingPage extends StatelessWidget {
  final String chapaTxRef;

  const OrderConfirmationLoadingPage({super.key, required this.chapaTxRef});

  Future<Map<String, dynamic>> _getOrderDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final orderData = prefs.getString('pending_order');
    if (orderData == null) {
      debugPrint('No pending order data found in SharedPreferences');
      return {'totalAmount': 0.0, 'deliveryAddress': 'Unknown Address'};
    }
    return jsonDecode(orderData) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          debugPrint('OrderCreated state received, navigating to confirmation with orderId: ${state.orderId}');
          _navigateToConfirmation(context, state.orderId);
        } else if (state is OrderError) {
          debugPrint('OrderError state received: ${state.message}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create order: ${state.message}')),
            );
            Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: _getOrderDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint('Error fetching order details: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final orderDetails = snapshot.data!;
            final txRef = orderDetails['txRef'] as String? ?? 'unknown_tx_ref';
            final totalAmount = orderDetails['totalAmount'] as double? ?? 0.0;
            final deliveryAddress = orderDetails['deliveryAddress']?.toString() ?? 'Unknown Address';
            final customerId = '67f3ddb5d84269b6463c0ede';
            final restaurantId = '681322cb7a5591e3a40ee78d';
            final cartItems = (orderDetails['cartItems'] as List?)?.cast<Map<String, dynamic>>() ?? [];
            final latitude = orderDetails['latitude'] as double? ?? 38.74;
            final longitude = orderDetails['longtiude'] as double? ?? 9.03;

            if (txRef.startsWith('eshi-tap-tx-')) {
              debugPrint('Initiating order creation with txRef: $txRef, chapaTxRef: $chapaTxRef');
              context.read<OrderBloc>().add(CreateOrderEvent(
                restaurantId: restaurantId,
                customerId: customerId,
                items: cartItems,
                orderStatus: 'delivered',
                totalAmount: totalAmount,
                latitude: latitude,
                longitude: longitude,
              ));
            } else {
              debugPrint('Invalid transaction reference in SharedPreferences: $txRef');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid transaction reference')),
                );
                Navigator.pop(context);
              });
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _navigateToConfirmation(BuildContext context, String orderId) {
    _getOrderDetails().then((orderDetails) {
      final totalAmount = orderDetails['totalAmount'] as double? ?? 0.0;
      final deliveryAddress = orderDetails['deliveryAddress']?.toString() ?? 'Unknown Address';
      debugPrint('Navigating to OrderConfirmationPage with orderId: $orderId, totalAmount: $totalAmount, deliveryAddress: $deliveryAddress');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            orderId: orderId,
            totalAmount: totalAmount,
            deliveryAddress: deliveryAddress,
          ),
        ),
      );
    }).catchError((error) {
      debugPrint('Error during navigation setup: $error');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: $error')),
        );
        Navigator.pop(context);
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }
}