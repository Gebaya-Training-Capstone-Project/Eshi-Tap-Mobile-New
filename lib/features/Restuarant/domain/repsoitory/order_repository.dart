import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart' as restaurant_entity;

abstract class OrderRepository {
  Future<Either<Failure, restaurant_entity.Order>> createOrder({
    required String restaurantId,
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
    required String deliveryAddress,
    required String phoneNumber,
    required String txRef,
  });

  Future<Either<Failure, restaurant_entity.Order>> getOrderById(String orderId);
}