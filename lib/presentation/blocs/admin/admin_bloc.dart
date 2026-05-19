import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/analytics_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/admin_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminDashboardRequested extends AdminEvent {}
class AdminStudentsRequested extends AdminEvent {
  final String? query;
  AdminStudentsRequested({this.query});
  @override
  List<Object?> get props => [query];
}
class AdminToggleStudentStatus extends AdminEvent {
  final int userId;
  final bool isActive;
  AdminToggleStudentStatus({required this.userId, required this.isActive});
  @override
  List<Object?> get props => [userId, isActive];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminDashboardLoaded extends AdminState {
  final AnalyticsModel analytics;
  AdminDashboardLoaded(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class AdminStudentsLoaded extends AdminState {
  final List<AdminUserModel> students;
  AdminStudentsLoaded(this.students);
  @override
  List<Object?> get props => [students];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;

  AdminBloc({required AdminRepository repository})
      : _repo = repository,
        super(AdminInitial()) {
    on<AdminDashboardRequested>(_onDashboard);
    on<AdminStudentsRequested>(_onStudents);
    on<AdminToggleStudentStatus>(_onToggleStatus);
  }

  Future<void> _onDashboard(
      AdminDashboardRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final analytics = await _repo.getAnalytics();
      emit(AdminDashboardLoaded(analytics));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onStudents(
      AdminStudentsRequested event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final students = await _repo.getStudents(query: event.query);
      emit(AdminStudentsLoaded(students));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onToggleStatus(
      AdminToggleStudentStatus event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateStudentStatus(event.userId, isActive: event.isActive);
      // Reload the list
      add(AdminStudentsRequested());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
