import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/order_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart' as EntityOrder;
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/order_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EntityOrder.Order>> createOrder({
    required String restaurantId,
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
    required String deliveryAddress,
    required String phoneNumber,
    required String txRef,
  }) async {
    try {
      final token = await _getToken();
      final order = await remoteDataSource.createOrder(
        restaurantId: restaurantId,
        customerId: customerId,
        items: items,
        orderStatus: orderStatus,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        txRef: txRef,
        token: token,
      );
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EntityOrder.Order>> getOrderById(String orderId) async {
    try {
      final token = await _getToken();
      final order = await remoteDataSource.getOrderById(orderId, token);
      return Right(order);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      throw Exception('User not authenticated. Please log in again.');
    }
    return token;
  }
}