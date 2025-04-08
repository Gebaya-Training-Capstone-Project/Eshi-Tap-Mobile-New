

import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';

class GetRestaurants {
  final RestaurantRepository repository;

  GetRestaurants(this.repository);

  Future<List<Restaurant>> call() async {
    return await repository.getRestaurants();
  }
}