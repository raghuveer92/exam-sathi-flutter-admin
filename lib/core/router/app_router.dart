import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/chapters/chapters_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/exams/exams_screen.dart';
import '../../presentation/screens/students/students_screen.dart';
import '../../presentation/screens/shell/admin_shell.dart';
import '../../presentation/screens/subjects/subjects_screen.dart';
import '../../presentation/screens/topics/topics_screen.dart';
import 'route_extra.dart';

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
    refreshListenable: _GoRouterRefreshStream(GetIt.I<AuthBloc>().stream),
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
            routes: [
              GoRoute(
                path: ':examId/subjects',
                builder: (context, state) {
                  final examId = int.parse(state.pathParameters['examId']!);
                  final routeExtra = RouteExtra.forSubjects(state.extra);
                  return SubjectsScreen(
                    examId: examId,
                    examName: routeExtra.examName,
                  );
                },
                routes: [
                  GoRoute(
                    path: ':subjectId/chapters',
                    builder: (context, state) {
                      final examId = int.parse(state.pathParameters['examId']!);
                      final subjectId = int.parse(state.pathParameters['subjectId']!);
                      final routeExtra = RouteExtra.forChapters(state.extra);
                      return ChaptersScreen(
                        examId: examId,
                        subjectId: subjectId,
                        examName: routeExtra.examName,
                        subjectName: routeExtra.subjectName,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':chapterId/topics',
                        builder: (context, state) {
                          final examId = int.parse(state.pathParameters['examId']!);
                          final subjectId = int.parse(state.pathParameters['subjectId']!);
                          final chapterId = int.parse(state.pathParameters['chapterId']!);
                          final routeExtra = RouteExtra.forTopics(state.extra);
                          return TopicsScreen(
                            examId: examId,
                            subjectId: subjectId,
                            chapterId: chapterId,
                            examName: routeExtra.examName,
                            subjectName: routeExtra.subjectName,
                            chapterTitle: routeExtra.chapterTitle,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
  late final StreamSubscription<dynamic> _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
