import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Restuarant/data/model/meals_model.dart';

abstract class MealRemoteDataSource {
  Future<List<MealModel>> getAllMeals({
    String searchQuery = '',
    bool isFasting = false,
  });
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  MealRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MealModel>> getAllMeals({
    String searchQuery = '',
    bool isFasting = false,
  }) async {
    try {
      // Build query parameters
      final queryParameters = <String, dynamic>{};
      if (searchQuery.isNotEmpty) {
        queryParameters['search'] = searchQuery;
      }
      if (isFasting) {
        queryParameters['isFasting'] = 'true';
      }

      final response = await dio.get(
        '$baseUrl/meal',
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        return (response.data['data'] as List)
            .map((json) => MealModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to fetch meals: ${response.data['message']}');
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }
}