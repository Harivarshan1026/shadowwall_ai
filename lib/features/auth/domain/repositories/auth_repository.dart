/// Auth repository contract — domain layer interface.
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with email and password.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in anonymously / guest access.
  Future<Either<Failure, UserEntity>> signInAnonymously();

  /// Register with email and password.
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Send password reset email.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Sign out.
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Check biometric availability and authenticate.
  Future<Either<Failure, bool>> authenticateWithBiometrics();

  /// Check if biometrics are available.
  Future<bool> isBiometricAvailable();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
