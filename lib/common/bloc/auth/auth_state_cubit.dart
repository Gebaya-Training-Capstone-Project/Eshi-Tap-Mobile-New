
// import 'package:eshi_tap/common/bloc/auth/auth_state.dart';
// import 'package:eshi_tap/features/Auth/domain/usecases/is_logged_in.dart';
// import 'package:eshi_tap/injection_container.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class AuthStateCubit extends Cubit<AuthState> {

//   AuthStateCubit() : super(AppInitialState());
  
//   void appStarted() async {
//     var isLoggedIn = await sl<IsLoggedInUseCase>().call();
//     if (isLoggedIn) {
//       emit(Authenticated());
//     } else {
//       emit(UnAuthenticated());
//     }
//   }

// }