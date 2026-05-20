import 'dart:async';

import 'package:agri_core/agri_core.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notifies [GoRouter] when Supabase auth state changes.
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(SupabaseAuthService authService) {
    _subscription = authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
