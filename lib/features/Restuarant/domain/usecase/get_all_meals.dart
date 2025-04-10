import 'package:dartz/dartz.dart';
import 'package:eshi_tap/core/error/failures.dart';
import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/meal_repository.dart';


class GetAllMeals {
  final MealRepository repository;

  GetAllMeals(this.repository);

  Future<Either<Failure, List<Meal>>> call() async {
    return await repository.getAllMeals();
  }
}