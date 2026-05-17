import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:since_together/features/auth/presentation/login_page.dart';
import 'package:since_together/features/auth/presentation/register_page.dart';
import 'package:since_together/features/couple/presentation/invite_page.dart';
import 'package:since_together/features/home/presentation/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = Supabase.instance.client.auth.currentUser;
      final loggedIn = user != null;
      final onAuth =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !onAuth) return '/login';
      if (loggedIn && onAuth) return '/invite';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/invite', builder: (_, _) => const InvitePage()),
      GoRoute(path: '/home', builder: (_, _) => const HomePage()),
    ],
  );
});
