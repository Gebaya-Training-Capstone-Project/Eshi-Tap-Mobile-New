import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart' as entity;
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/order_repository.dart';

class GetOrderById {
  final OrderRepository repository;

  GetOrderById(this.repository);

  Future<Either<Failure, entity.Order>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}