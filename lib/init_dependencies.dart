import 'package:bolg_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bolg_app/core/secrets/app_secrets.dart';
import 'package:bolg_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bolg_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bolg_app/features/auth/domain/repository/auth_repository.dart';
import 'package:bolg_app/features/auth/domain/usecases/current_user.dart';
import 'package:bolg_app/features/auth/domain/usecases/user_login.dart';
import 'package:bolg_app/features/auth/domain/usecases/user_sign_up.dart';
import 'package:bolg_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  //core
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabaseClient: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserSignUp(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => UserLogin(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => CurrentUser(
      authRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignUp: serviceLocator(),
      userLogin: serviceLocator(),
      currentUser: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}
