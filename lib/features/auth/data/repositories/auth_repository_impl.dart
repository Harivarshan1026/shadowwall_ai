import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:flutter/foundation.dart';

/// REAL FIREBASE AUTHENTICATION REPOSITORY
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final LocalAuthentication _localAuth;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    LocalAuthentication? localAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _localAuth = localAuth ?? LocalAuthentication();

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'Cyber Defender',
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return _mapFirebaseUser(user);
      }
      return null;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return Left(AuthFailure(message: 'Email and password cannot be empty.'));
      }
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return Right(_mapFirebaseUser(userCredential.user!));
      }
      return Left(AuthFailure(message: 'Sign in failed: User is null'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow with the Web Client ID
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: '883269776134-fsmbsq1tov13j3krqv7k3hobi0akf0hc.apps.googleusercontent.com',
      ).signIn();
      
      // If the user cancels the sign-in popup
      if (googleUser == null) {
        return Left(AuthFailure(message: 'Google Sign-In was canceled.'));
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        return Right(_mapFirebaseUser(userCredential.user!));
      }
      return Left(AuthFailure(message: 'Google Sign-In failed: User is null'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Google Sign-In failed on Firebase.'));
    } catch (e) {
      return Left(AuthFailure(message: 'Google Sign-In Error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return Left(AuthFailure(message: 'Fields cannot be empty.'));
      }
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        return Right(_mapFirebaseUser(userCredential.user!));
      }
      return Left(AuthFailure(message: 'Registration failed: User is null'));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Failed to send reset email'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return Right(_mapFirebaseUser(user));
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to get current user'));
    }
  }

  @override
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    return await _localAuth.canCheckBiometrics;
  }

  @override
  Future<Either<Failure, bool>> authenticateWithBiometrics() async {
    try {
      if (kIsWeb) {
        return Left(AuthFailure(message: 'Biometrics are not supported on Web.'));
      }
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return Left(AuthFailure(message: 'Biometrics not available on this device.'));
      }
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      return Right(authenticated);
    } catch (e) {
      return Left(AuthFailure(message: 'Biometric Auth Error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed'));
    }
  }
}
