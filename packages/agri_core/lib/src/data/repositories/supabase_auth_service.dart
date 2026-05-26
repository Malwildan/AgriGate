import 'dart:io';

import 'package:supabase/supabase.dart';

import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';
import '../../support/app_logger.dart';

class SupabaseAuthService implements UserSessionGate {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<Either<Failure, void>> sendEmailOtp(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      return const Left(ValidationFailure('Masukkan alamat email yang valid.'));
    }

    try {
      await _client.auth.signInWithOtp(
        email: normalized,
        shouldCreateUser: true,
      );
      AppLogger.i('OTP email requested', tag: 'auth');
      return const Right(null);
    } on AuthException catch (error) {
      AppLogger.w('OTP request failed', tag: 'auth', error: error);
      return Left(AuthFailure(error.message));
    } on SocketException catch (error) {
      return Left(NetworkFailure('Gagal menghubungi Supabase: $error'));
    } catch (error) {
      return Left(AuthFailure('Gagal mengirim kode masuk: $error'));
    }
  }

  Future<Either<Failure, void>> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final normalized = email.trim().toLowerCase();
    final code = token.trim();
    if (code.length < 6) {
      return const Left(ValidationFailure('Kode OTP minimal 6 digit.'));
    }

    try {
      await _client.auth.verifyOTP(
        email: normalized,
        token: code,
        type: OtpType.email,
      );
      AppLogger.i('User signed in', tag: 'auth');
      return const Right(null);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on SocketException catch (error) {
      return Left(NetworkFailure('Gagal menghubungi Supabase: $error'));
    } catch (error) {
      return Left(AuthFailure('Verifikasi OTP gagal: $error'));
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    AppLogger.i('User signed out', tag: 'auth');
  }

  @override
  Future<Either<Failure, String>> requireUserId() async {
    final user = currentUser;
    if (user == null) {
      return const Left(AuthFailure('Silakan masuk untuk menyinkronkan data.'));
    }
    if (user.isAnonymous) {
      return const Left(
        AuthFailure('Akun anonim tidak didukung. Gunakan masuk via email.'),
      );
    }
    return Right(user.id);
  }
}
