import 'package:bolg_app/core/error/failures.dart';
import 'package:bolg_app/core/usecase/usecase.dart';
import 'package:bolg_app/core/common/entities/user.dart';
import 'package:bolg_app/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  CurrentUser({required this.authRepository});
  @override
  Future<Either<Failure, User>> call(NoParams params) async{
     return await authRepository.currentUser();
  }

}

