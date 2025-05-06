import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/data/model/order_model.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/order.dart' as entity;
import 'package:get_it/get_it.dart';

class CreateOrder {
  final Dio dio = GetIt.instance<Dio>();

  Future<Either<Failure, entity.Order>> call({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String orderStatus,
    required double totalAmount,
  }) async {
    try {
      final response = await dio.post(
        'https://eshi-tap.vercel.app/api/order',
        data: {
          'restaurant': restaurantId,
          'items': items,
          'orderStatus': orderStatus,
          'totalAmount': totalAmount,
        },
        options: Options(
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZjNkZGI1ZDg0MjY5YjY0NjNjMGVkZSIsInJvbGUiOiJjdXN0b21lciIsImVtYWlsIjoibmViaW1vYmlsZUBnbWFpbC5jb20iLCJpYXQiOjE3NDYxMTk2MDAsImV4cCI6MTc0ODcxMTYwMH0.POQyG_yEWzRYzTnru_5FELM7reHdqBqCyxNNpFZwC6A',
          },
        ),
      );

      if (response.statusCode == 201) {
        final order = OrderModel.fromJson(response.data['data'][0]);
        return Right(order);
      } else {
        return Left(ServerFailure(message: response.data['message'] ?? 'Failed to create order'));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}