import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Restuarant/data/model/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String restaurantId,
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
    required String deliveryAddress,
    required String phoneNumber,
    required String txRef,
    required String token,
  });

  Future<OrderModel> getOrderById(String orderId, String token);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  OrderRemoteDataSourceImpl(this.dio);

  @override
  Future<OrderModel> createOrder({
    required String restaurantId,
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
    required String deliveryAddress,
    required String phoneNumber,
    required String txRef,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/order',
        data: {
          'restaurant': restaurantId,
          'customer': customerId,
          'items': items,
          'orderStatus': orderStatus,
          'totalAmount': totalAmount,
          'deliveryAddress': deliveryAddress,
          'phoneNumber': phoneNumber,
          'payment': {
            'method': 'chapa',
            'status': 'completed',
            'transactionId': txRef,
            'paymentDate': DateTime.now().toIso8601String(),
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson((response.data['data'] as List).first);
      }
      throw Exception('Failed to create order: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId, String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/order/$orderId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch order: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }
}