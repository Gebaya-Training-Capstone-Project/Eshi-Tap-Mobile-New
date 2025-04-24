import 'dart:io';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/injection_container.dart' as di;
import 'package:eshi_tap/features/Restuarant/presentation/address_selection_page.dart';
import 'package:eshi_tap/features/Restuarant/presentation/order_tracker_page.dart';

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
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
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
                restaurantId: args?['restaurantId'] ?? 'default_id',
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
          } else if (settings.name!.startsWith('/order_tracker')) {
            final uri = Uri.parse(settings.name!);
            final txRef = uri.queryParameters['tx_ref'] ?? 'unknown_tx_ref';
            return MaterialPageRoute(
              builder: (context) => OrderTrackerPage(orderId: txRef),
            );
          }
          return null;
        },
      ),
    );
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