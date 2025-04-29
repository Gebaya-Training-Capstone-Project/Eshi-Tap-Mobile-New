part of 'restaurant_bloc.dart';

abstract class RestaurantEvent {}

class FetchRestaurants extends RestaurantEvent {
  final String searchQuery;

  FetchRestaurants({this.searchQuery = ''});
}