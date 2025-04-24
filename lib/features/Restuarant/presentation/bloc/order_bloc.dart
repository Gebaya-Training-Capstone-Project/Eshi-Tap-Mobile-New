import 'dart:io';

import 'package:dio/dio.dart';

import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_event.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderState.initial()) {
    on<PlaceOrder>(_onPlaceOrder);
    on<PaymentSuccessful>(_onPaymentSuccessful);
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(state.copyWith(paymentStatus: PaymentStatus.loading));

      const String orderApiUrl = 'YOUR_ORDER_API_URL'; // Replace with actual URL
      const String customerId = 'YOUR_CUSTOMER_ID';
      const String restaurantId = 'YOUR_RESTAURANT_ID';

      final response = await http.post(
        Uri.parse(orderApiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'restaurant': restaurantId,
          'customer': customerId,
          'items': event.cartItems,
          'orderStatus': 'pending',
          'totalAmount': event.totalAmount,
          'deliveryAddress': event.address,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final paymentUrl = data['paymentUrl'] ?? '';
        final transactionId = data['transactionId'] ?? 'tx_${DateTime.now().millisecondsSinceEpoch}';
        emit(state.copyWith(
          paymentStatus: PaymentStatus.loaded,
          paymentUrl: paymentUrl,
          transactionId: transactionId,
        ));
      } else {
        throw Exception('Failed to initiate payment: ${response.body}');
      }
    } catch (e) {
      String errorMessage = 'Something went wrong';
      if (e is DioException) {
        if (e.error is SocketException) {
          errorMessage = "No Internet Connection!";
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = "Request timeout";
        } else if (e.type == DioExceptionType.badResponse) {
          final response = e.response;
          if (response != null && response.data != null) {
            try {
              final Map responseData = response.data as Map;
              errorMessage = responseData['msg'] ?? 'Something went wrong';
            } catch (_) {
              errorMessage = 'Something went wrong';
            }
          }
        }
      } else {
        errorMessage = e.toString();
      }
      emit(state.copyWith(
        paymentStatus: PaymentStatus.error,
        errorMessage: errorMessage,
      ));
    }
  }

  void _onPaymentSuccessful(
    PaymentSuccessful event,
    Emitter<OrderState> emit,
  ) {
    emit(state.copyWith(paymentStatus: PaymentStatus.success));
  }
}