/// Auth state and providers using Riverpod.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/config/env_config.dart';

// ──────────── Repository Provider ────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// ──────────── Use Case Providers ────────────

final signInWithEmailProvider = Provider((ref) {
  return SignInWithEmail(ref.read(authRepositoryProvider));
});

final signInWithGoogleProvider = Provider((ref) {
  return SignInWithGoogle(ref.read(authRepositoryProvider));
});

final signInAnonymouslyProvider = Provider((ref) {
  return SignInAnonymously(ref.read(authRepositoryProvider));
});

final signUpProvider = Provider((ref) {
  return SignUp(ref.read(authRepositoryProvider));
});

final forgotPasswordProvider = Provider((ref) {
  return ForgotPassword(ref.read(authRepositoryProvider));
});

final biometricAuthProvider = Provider((ref) {
  return BiometricAuth(ref.read(authRepositoryProvider));
});

// ──────────── Auth State ────────────

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ──────────── Auth Notifier ────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAnonymously _signInAnonymously;
  final SignUp _signUp;
  final ForgotPassword _forgotPassword;
  final BiometricAuth _biometricAuth;
  final AuthRepository _repository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthNotifier({
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInAnonymously signInAnonymously,
    required SignUp signUp,
    required ForgotPassword forgotPassword,
    required BiometricAuth biometricAuth,
    required AuthRepository repository,
  })  : _signInWithEmail = signInWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signInAnonymously = signInAnonymously,
        _signUp = signUp,
        _forgotPassword = forgotPassword,
        _biometricAuth = biometricAuth,
        _repository = repository,
        super(
          EnvConfig.isUserLoggedIn
              ? AuthState(
                  status: AuthStatus.authenticated,
                  user: UserEntity(
                    uid: EnvConfig.userUid ?? 'persisted-device-user',
                    email: EnvConfig.userEmail ?? 'user@shadowwall.ai',
                    displayName: EnvConfig.userDisplayName ?? 'Cyber Defender',
                    isEmailVerified: true,
                  ),
                )
              : const AuthState(status: AuthStatus.initial),
        ) {
    _initAuth();
  }

  void _initAuth() {
    _authSubscription = _repository.authStateChanges.listen((user) {
      if (user != null) {
        EnvConfig.saveUserSession(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }
    });

    if (!EnvConfig.isUserLoggedIn) {
      _checkCurrentUser();
    }
  }

  Future<void> _checkCurrentUser() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (_) {},
      (user) {
        if (user != null) {
          EnvConfig.saveUserSession(
            uid: user.uid,
            email: user.email,
            displayName: user.displayName,
          );
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signInWithEmail(email: email, password: password);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signInWithGoogle();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signInAnonymously();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> signUp(String email, String password, String displayName) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signUp(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _forgotPassword(email: email);

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> authenticateWithBiometrics() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _biometricAuth();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        if (success) {
          state = state.copyWith(status: AuthStatus.authenticated);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Biometric authentication failed',
          );
        }
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    await EnvConfig.clearUserSession();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}

// ──────────── Auth State Provider ────────────

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInWithEmail: ref.read(signInWithEmailProvider),
    signInWithGoogle: ref.read(signInWithGoogleProvider),
    signInAnonymously: ref.read(signInAnonymouslyProvider),
    signUp: ref.read(signUpProvider),
    forgotPassword: ref.read(forgotPasswordProvider),
    biometricAuth: ref.read(biometricAuthProvider),
    repository: ref.read(authRepositoryProvider),
  );
});
