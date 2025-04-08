import 'package:eshi_tap/features/Restuarant/domain/entity/restaurant.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurants getRestaurants;

  RestaurantBloc(this.getRestaurants) : super(RestaurantInitial()) {
    on<FetchRestaurants>((event, emit) async {
      emit(RestaurantLoading());
      try {
        final restaurants = await getRestaurants();
        emit(RestaurantLoaded(restaurants));
      } catch (e) {
        emit(RestaurantError(e.toString()));
      }
    });
  }
}