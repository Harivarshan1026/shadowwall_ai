/// Auth use cases — domain layer business logic.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Sign in with email and password.
class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }
}

/// Sign in with Google.
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}

/// Sign in anonymously / guest.
class SignInAnonymously {
  final AuthRepository repository;

  SignInAnonymously(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInAnonymously();
  }
}

/// Sign up with email and password.
class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

/// Send password reset email.
class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.forgotPassword(email: email);
  }
}

/// Authenticate with biometrics.
class BiometricAuth {
  final AuthRepository repository;

  BiometricAuth(this.repository);

  Future<Either<Failure, bool>> call() {
    return repository.authenticateWithBiometrics();
  }

  Future<bool> isAvailable() {
    return repository.isBiometricAvailable();
  }
}
