import 'dart:io';

import 'package:supabase/supabase.dart';

import '../../domain/failures/failures.dart';
import '../../domain/repositories/repositories.dart';

class SupabaseSessionService {
  const SupabaseSessionService(this._client);

  final SupabaseClient _client;

  Future<Either<Failure, String>> ensureAnonymousSession() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        return Right(currentUser.id);
      }

      final response = await _client.auth.signInAnonymously();
      final user = response.user ?? _client.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Sesi anonim Supabase tidak tersedia.'));
      }

      return Right(user.id);
    } on AuthException catch (error) {
      return Left(AuthFailure(error.message));
    } on SocketException catch (error) {
      return Left(NetworkFailure('Gagal menghubungi Supabase: $error'));
    } catch (error) {
      return Left(AuthFailure('Gagal menyiapkan sesi backend: $error'));
    }
  }
}