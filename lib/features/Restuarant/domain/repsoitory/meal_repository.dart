import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';

abstract class MealRepository {
  Future<Either<Failure, List<Meal>>> getAllMeals();
}