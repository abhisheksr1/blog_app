import 'package:bolg_app/core/constants/constants.dart';
import 'package:bolg_app/core/error/exception.dart';
import 'package:bolg_app/core/error/failures.dart';
import 'package:bolg_app/core/network/connection_checker.dart';
import 'package:bolg_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bolg_app/core/common/entities/user.dart';
import 'package:bolg_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User Not Logged In'));
        }
        return right(User(
          id: session.user.id,
          email: session.user.email ?? '',
          name: '',
        ));
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user != null) {
        return right(user);
      }
      return left(Failure('User Not Logged In'));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await fn();
      return right(user);
    }on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
