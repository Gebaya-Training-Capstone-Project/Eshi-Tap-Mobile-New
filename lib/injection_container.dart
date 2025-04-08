import 'package:dio/dio.dart';
import 'package:eshi_tap/features/Auth/data/repository/auth.dart';
import 'package:eshi_tap/features/Auth/data/source/auth_api_service.dart';
import 'package:eshi_tap/features/Auth/domain/repository/auth.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/get_user.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/logout.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signin.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signup.dart';
import 'package:eshi_tap/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:eshi_tap/features/Restuarant/data/repository/restaurant_repository_impl.dart';
import 'package:eshi_tap/features/Restuarant/data/sources/restaurant_remote_datasource.dart';
import 'package:eshi_tap/features/Restuarant/domain/repsoitory/restaurant_repository.dart';
import 'package:eshi_tap/features/Restuarant/domain/usecase/get_restaurants.dart';
import 'package:eshi_tap/features/Restuarant/presentation/bloc/restaurant_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => FlutterSecureStorage());

  // Data sources
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => RestaurantRemoteDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetLoggedInUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetRestaurants(sl()));

  // Blocs
  sl.registerFactory(() => AuthBloc(
        registerUser: sl(),
        loginUser: sl(),
        getLoggedInUser: sl(),
        logoutUser: sl(),
      ));
  sl.registerFactory(() => RestaurantBloc(sl()));
}