import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Restuarant/data/model/meals_model.dart';

abstract class MealRemoteDataSource {
  Future<List<MealModel>> getAllMeals();
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final Dio dio;
  static const baseUrl = 'https://eshi-tap.vercel.app/api';

  MealRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MealModel>> getAllMeals() async {
    try {
      final response = await dio.get('$baseUrl/meal');
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