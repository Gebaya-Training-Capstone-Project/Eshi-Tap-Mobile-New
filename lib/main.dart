import 'dart:io';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/address_selection_page.dart';
import 'package:eshi_tap/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eshi_tap/injection_container.dart' as di;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  try {
    await dotenv.load(fileName: '.env'); // Update path for web and mobile
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    dotenv.env['CHAPA_PUBLIC_KEY'] = 'CHAPUBK_TEST-GkaAX3iPTDYqOJYOlGMmbkwgHas8YDwv';
  }
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
        routes: {
          '/address_selection': (context) => AddressSelectionPage(
                totalAmount: ModalRoute.of(context)!.settings.arguments as double,
                cartItems: [],
                restaurantId: 'default_id',
                onPlaceOrder: (address, reference) {
                  debugPrint('Order placed at $address with ref $reference');
                },
              ),
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}