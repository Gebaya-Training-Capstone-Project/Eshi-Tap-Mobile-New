import 'package:eshi_tap/features/Restuarant/domain/entity/meal.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_all_meals.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MealEvent {}

class FetchMeals extends MealEvent {
  final String searchQuery;
  final bool isFasting;

  FetchMeals({this.searchQuery = '', this.isFasting = false});
}

abstract class MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final List<Meal> meals;

  MealLoaded(this.meals);
}

class MealError extends MealState {
  final String message;

  MealError(this.message);
}

class MealBloc extends Bloc<MealEvent, MealState> {
  final GetAllMeals getAllMeals;

  MealBloc(this.getAllMeals) : super(MealLoading()) {
    on<FetchMeals>((event, emit) async {
      emit(MealLoading());
      final result = await getAllMeals(
        searchQuery: event.searchQuery,
        isFasting: event.isFasting,
      );
      result.fold(
        (failure) => emit(MealError('Failed to load meals')),
        (meals) => emit(MealLoaded(meals)),
      );
    });
  }
}