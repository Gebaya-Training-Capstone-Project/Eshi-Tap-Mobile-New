import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/data/model/meals_model.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/meal_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/meal_repository.dart';


class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Meal>>> getAllMeals() async {
    try {
      final mealModels = await remoteDataSource.getAllMeals();
      final meals = mealModels.map((model) => model.toEntity()).toList();
      return Right(meals);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch meals'));
    }
  }
}