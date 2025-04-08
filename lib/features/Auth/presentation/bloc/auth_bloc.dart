import 'package:eshi_tap/features/Auth/domain/entities/user.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/get_user.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/logout.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signin.dart';
import 'package:eshi_tap/features/Auth/domain/usecases/signup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final GetLoggedInUser getLoggedInUser;
  final LogoutUser logoutUser;

  AuthBloc({
    required this.registerUser,
    required this.loginUser,
    required this.getLoggedInUser,
    required this.logoutUser,
  }) : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await registerUser(
          username: event.username,
          email: event.email,
          password: event.password,
          phone: event.phone,
          address: event.address,
        );
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUser(event.username, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckAuthEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await getLoggedInUser();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await logoutUser();
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}