import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
}