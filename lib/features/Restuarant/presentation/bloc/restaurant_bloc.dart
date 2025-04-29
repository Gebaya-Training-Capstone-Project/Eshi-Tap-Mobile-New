import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'restaurant_event.dart';
// part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;

  RestaurantBloc(this.getRestaurants) : super(RestaurantInitial()) {
    on<FetchRestaurants>((event, emit) async {
      emit(RestaurantLoading());
      final result = await getRestaurants(searchQuery: event.searchQuery);
      result.fold(
        (failure) => emit(RestaurantError(failure.message)),
        (restaurants) => emit(RestaurantLoaded(restaurants)),
      );
    });
  }
}

abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final List<Restaurant> restaurants;

  RestaurantLoaded(this.restaurants);
}

class RestaurantError extends RestaurantState {
  final String message;

  RestaurantError(this.message);
}