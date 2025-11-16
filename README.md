# blog_application

Create model, repository, bloc with api localhost, exceptions handling, dio |All latest version using | full folder structure base on my response

Key Features:
Clean Architecture with proper separation of concerns
Dio for HTTP requests with interceptors
BLoC for state management
Exception handling with custom exceptions
Token-based authentication with refresh token support
Local storage using SharedPreferences
Dependency injection with GetIt
Form validation and error handling

{
    "accessToken": "eyJhbGciOiJIUzUxMiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzX3Rva2VuIiwic3ViIjoidXNlcjEwQGdtYWlsLmNvbSIsImlhdCI6MTc2MzIxNTM1NywiZXhwIjoxNzYzMjE1NjU3fQ.dEISXbGutm6movpq98BZu6GjcK4Vm2eXWOc5NVvZctKc0O5mMMSibbSxI7YGKfH7S6sCUEoWdNihxlQqLD6d0A",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaF90b2tlbiIsInN1YiI6InVzZXIxMEBnbWFpbC5jb20iLCJpYXQiOjE3NjMyMTUzNTcsImV4cCI6MTc2MzIxODk1N30.BlVP6kq-u-ODAFASUcuzMRTe6CH_vpNf9dPrBqrsT9xQ7qNnaRhxp1SOOvPwNmP44V2liX5TJvNCLj1avFAQqA",
    "email": "user10@gmail.com"
}

Below is a complete, production-ready Flutter clean-architecture template implementing everything you asked for:

✔ Clean Architecture (data → domain → presentation)
✔ Dio with Interceptors
✔ Token-based auth with refresh-token
✔ SharedPreferences for persistence
✔ BLoC state management
✔ GetIt dependency injection
✔ Exception handling + Failure classes
✔ API localhost example
✔ Fully structured folder tree
✔ Login example using your token response




lib/
└── src/
    ├── config/
    │   ├── dio/
    │   │   ├── dio_client.dart
    │   │   └── dio_interceptor.dart
    │   ├── injector.dart
    │   └── env.dart
    │
    ├── core/
    │   ├── errors/
    │   │   ├── exceptions.dart
    │   │   └── failures.dart
    │   ├── usecases/usecase.dart
    │   ├── storage/local_storage.dart
    │   └── utils/validators.dart
    │
    ├── features/
    │   └── auth/
    │       ├── data/
    │       │   ├── models/auth_response.dart
    │       │   ├── datasources/auth_remote.dart
    │       │   └── repositories/auth_repo_impl.dart
    │       ├── domain/
    │       │   ├── entities/user_entity.dart
    │       │   ├── repositories/auth_repo.dart
    │       │   └── usecases/login_usecase.dart
    │       └── presentation/
    │           ├── bloc/auth_bloc.dart
    │           └── pages/login_page.dart
    │
    └── app.dart

main.dart


===============================
📂 DATA LAYER (unchanged)
===============================

All previously provided files remain the same:

data/models/auth_response.dart
data/datasources/auth_remote_datasource.dart
data/repositories/auth_repository_impl.dart

(They already work without GetIt.)

===============================
📂 DOMAIN LAYER (unchanged)
===============================
domain/entities/user_entity.dart
domain/repositories/auth_repository.dart
domain/usecases/login_usecase.dart

Nothing changes.

===============================
📂 CORE LAYER (unchanged except DI removal)
===============================

All files previously provided are correct:

core/constants/env.dart
core/exceptions/exceptions.dart
core/exceptions/failures.dart
core/utils/local_storage.dart
core/utils/dio_client.dart
core/utils/dio_interceptor.dart
core/utils/validators.dart

No DI-related edits needed.

===============================
📂 PRESENTATION LAYER (unchanged)
===============================

All remain the same:

presentation/bloc/auth_bloc.dart
presentation/bloc/auth_event.dart
presentation/bloc/auth_state.dart
presentation/pages/login_page.dart

No GetIt inside them.

🎉 YOU NOW HAVE A CLEAN-ARCHITECTURE APP WITH MANUAL DI
✔ No GetIt
✔ Clean
✔ Testable
✔ Refresh Token
✔ Dio + Interceptor
✔ BLoC
✔ SharedPrefs
✔ Localhost-ready