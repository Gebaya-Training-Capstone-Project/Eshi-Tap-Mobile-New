import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Auth/data/repository/auth.dart';
import 'package:eshi_tap/features/Auth/data/source/auth_api_service.dart';
import 'package:eshi_tap/features/Auth/data/source/auth_local_service.dart';
import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/get_user.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/logout.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signin.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signup.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/data/repository/meal_repository_impl.dart';
import 'package:eshi_tap/features/Restuarant/data/repository/restaurant_repository_impl.dart';
import 'package:eshi_tap/features/Restuarant/data/repository/order_repository_impl.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/meal_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/restaurant_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/order_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/meal_repository.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/order_repository.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_all_meals.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/create_order.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_order_by_id.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/meal_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/order_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://eshi-tap.vercel.app/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Optional: Add interceptors for logging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));

    return dio;
  });

  sl.registerLazySingleton(() => FlutterSecureStorage());

  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<MealRemoteDataSource>(
    () => MealRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalService>(() => AuthLocalServiceImpl());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), secureStorage: sl(), localService: sl()),
  );
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetLoggedInUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetRestaurants(sl()));
  sl.registerLazySingleton(() => GetAllMeals(sl()));
  sl.registerLazySingleton(() => CreateOrder(sl()));
  sl.registerLazySingleton(() => GetOrderById(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(
        registerUser: sl(),
        loginUser: sl(),
        getLoggedInUser: sl(),
        logoutUser: sl(),
      ));
  sl.registerFactory(() => RestaurantBloc(sl()));
  sl.registerFactory(() => MealBloc(sl()));
  sl.registerFactory(() => OrderBloc(sl(), sl()));
}