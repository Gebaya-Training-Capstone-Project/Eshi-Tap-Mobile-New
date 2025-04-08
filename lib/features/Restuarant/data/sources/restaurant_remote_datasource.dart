import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Restuarant/data/model/restaurant_model.dart';


class RestaurantRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  RestaurantRemoteDataSource(this.dio);

  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await dio.get('$baseUrl/restaurant');
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((json) => RestaurantModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to fetch restaurants: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }
}