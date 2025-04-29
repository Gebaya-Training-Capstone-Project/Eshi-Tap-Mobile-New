import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<Either<Failure, List<Restaurant>>> call({String searchQuery = ''}) async {
    return await repository.getRestaurants(searchQuery: searchQuery);
  }
}