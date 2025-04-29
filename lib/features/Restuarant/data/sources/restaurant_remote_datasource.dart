import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Restuarant/data/model/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getRestaurants({String searchQuery = ''});
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  RestaurantRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RestaurantModel>> getRestaurants({String searchQuery = ''}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (searchQuery.isNotEmpty) {
        queryParameters['search'] = searchQuery;
      }

      final response = await dio.get(
        '$baseUrl/restaurant',
        queryParameters: queryParameters,
      );
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