import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/exams/exams_screen.dart';
import '../../presentation/screens/students/students_screen.dart';
import '../../presentation/screens/shell/admin_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final loggedIn = authState is AuthAuthenticated;
      final goingToLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/dashboard';
      return null;
    },
    refreshListenable: _GoRouterRefreshStream(),
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/exams',
            builder: (_, __) => const ExamsScreen(),
          ),
          GoRoute(
            path: '/students',
            builder: (_, __) => const StudentsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Connects GoRouter's refresh mechanism to BLoC state changes.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream() {
    notifyListeners();
  }
}
