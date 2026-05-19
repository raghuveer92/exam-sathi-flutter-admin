import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/exam_model.dart';
import '../../../data/repositories/exam_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class ExamEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExamsLoadRequested extends ExamEvent {}
class ExamCreateRequested extends ExamEvent {
  final Map<String, dynamic> data;
  ExamCreateRequested(this.data);
  @override
  List<Object?> get props => [data];
}
class ExamUpdateRequested extends ExamEvent {
  final int id;
  final Map<String, dynamic> data;
  ExamUpdateRequested({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}
class ExamDeleteRequested extends ExamEvent {
  final int id;
  ExamDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class ExamState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {}
class ExamLoading extends ExamState {}
class ExamError extends ExamState {
  final String message;
  ExamError(this.message);
  @override
  List<Object?> get props => [message];
}
class ExamsLoaded extends ExamState {
  final List<ExamModel> exams;
  ExamsLoaded(this.exams);
  @override
  List<Object?> get props => [exams];
}
class ExamOperationSuccess extends ExamState {}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ExamRepository _repo;

  ExamBloc({required ExamRepository repository})
      : _repo = repository,
        super(ExamInitial()) {
    on<ExamsLoadRequested>(_onLoad);
    on<ExamCreateRequested>(_onCreate);
    on<ExamUpdateRequested>(_onUpdate);
    on<ExamDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
      ExamsLoadRequested event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final exams = await _repo.getExams();
      emit(ExamsLoaded(exams));
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> _onCreate(
      ExamCreateRequested event, Emitter<ExamState> emit) async {
    try {
      await _repo.createExam(event.data);
      emit(ExamOperationSuccess());
      add(ExamsLoadRequested());
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      ExamUpdateRequested event, Emitter<ExamState> emit) async {
    try {
      await _repo.updateExam(event.id, event.data);
      emit(ExamOperationSuccess());
      add(ExamsLoadRequested());
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }

  Future<void> _onDelete(
      ExamDeleteRequested event, Emitter<ExamState> emit) async {
    try {
      await _repo.deleteExam(event.id);
      add(ExamsLoadRequested());
    } catch (e) {
      emit(ExamError(e.toString()));
    }
  }
}
