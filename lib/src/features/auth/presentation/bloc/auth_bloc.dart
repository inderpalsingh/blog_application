import 'package:blog_application/src/features/auth/domain/entities/auth_response_entity.dart';
import 'package:blog_application/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:blog_application/src/features/auth/presentation/bloc/auth_event.dart';

import 'package:blog_application/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:blog_application/src/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final Either<Failure, AuthResponseEntity> result = await loginUseCase(event.email, event.password);

    result.fold((failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (authResponse) => emit(AuthSuccess(authResponse.user, authResponse.accessToken)));
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'Unexpected error occurred';
  }
}
