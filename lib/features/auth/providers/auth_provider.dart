import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});
