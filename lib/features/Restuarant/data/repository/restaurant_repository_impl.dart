import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/data/model/restaurant_model.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/restaurant_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants({String searchQuery = ''}) async {
    try {
      final restaurantModels = await remoteDataSource.getRestaurants(searchQuery: searchQuery);
      final restaurants = restaurantModels.map((model) => model.toEntity()).toList();
      return Right(restaurants);
    } catch (e) {
      print('Error fetching restaurants: $e'); // Added logging
      return Left(ServerFailure(message: 'Failed to fetch restaurants: $e'));
    }
  }
}