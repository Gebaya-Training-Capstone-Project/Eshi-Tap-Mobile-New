

import 'package:eshi_tap/features/Restuarant/data/model/restaurant_model.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/restaurant_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final restaurantModels = await remoteDataSource.getRestaurants();
    return restaurantModels.map((model) => model.toEntity()).toList();
  }
}