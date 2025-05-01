import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart' as restaurant_entity;
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/order_repository.dart';

class CreateOrder {
  final OrderRepository repository;

  CreateOrder(this.repository);

  Future<Either<Failure, restaurant_entity.Order>> call({
    required String restaurantId,
    required String customerId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
    required String deliveryAddress,
    required String phoneNumber,
    required String txRef,
  }) async {
    return await repository.createOrder(
      restaurantId: restaurantId,
      customerId: customerId,
      items: items,
      orderStatus: orderStatus,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      phoneNumber: phoneNumber,
      txRef: txRef,
    );
  }
}