import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/subject_model.dart';
import '../../../data/repositories/subject_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class SubjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubjectsLoadRequested extends SubjectEvent {
  final int examId;
  SubjectsLoadRequested(this.examId);
  @override
  List<Object?> get props => [examId];
}

class SubjectCreateRequested extends SubjectEvent {
  final Map<String, dynamic> data;
  SubjectCreateRequested(this.data);
  @override
  List<Object?> get props => [data];
}

class SubjectUpdateRequested extends SubjectEvent {
  final int id;
  final Map<String, dynamic> data;
  SubjectUpdateRequested({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class SubjectDeleteRequested extends SubjectEvent {
  final int id;
  final int examId;
  SubjectDeleteRequested({required this.id, required this.examId});
  @override
  List<Object?> get props => [id, examId];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class SubjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectError extends SubjectState {
  final String message;
  SubjectError(this.message);
  @override
  List<Object?> get props => [message];
}

class SubjectsLoaded extends SubjectState {
  final List<SubjectModel> subjects;
  final int examId;
  SubjectsLoaded({required this.subjects, required this.examId});
  @override
  List<Object?> get props => [subjects, examId];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository _repository;

  SubjectBloc({required SubjectRepository repository})
      : _repository = repository,
        super(SubjectInitial()) {
    on<SubjectsLoadRequested>(_onLoad);
    on<SubjectCreateRequested>(_onCreate);
    on<SubjectUpdateRequested>(_onUpdate);
    on<SubjectDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(
      SubjectsLoadRequested event, Emitter<SubjectState> emit) async {
    emit(SubjectLoading());
    try {
      final subjects =
          await _repository.getSubjectsByExam(event.examId);
      emit(SubjectsLoaded(subjects: subjects, examId: event.examId));
    } catch (e) {
      emit(SubjectError(e.toString()));
    }
  }

  Future<void> _onCreate(
      SubjectCreateRequested event, Emitter<SubjectState> emit) async {
    final current = state;
    try {
      await _repository.createSubject(event.data);
      final examId = (event.data['examId'] as num).toInt();
      final subjects = await _repository.getSubjectsByExam(examId);
      emit(SubjectsLoaded(subjects: subjects, examId: examId));
    } catch (e) {
      emit(SubjectError(e.toString()));
      if (current is SubjectsLoaded) emit(current);
    }
  }

  Future<void> _onUpdate(
      SubjectUpdateRequested event, Emitter<SubjectState> emit) async {
    final current = state;
    try {
      await _repository.updateSubject(event.id, event.data);
      final examId = (event.data['examId'] as num).toInt();
      final subjects = await _repository.getSubjectsByExam(examId);
      emit(SubjectsLoaded(subjects: subjects, examId: examId));
    } catch (e) {
      emit(SubjectError(e.toString()));
      if (current is SubjectsLoaded) emit(current);
    }
  }

  Future<void> _onDelete(
      SubjectDeleteRequested event, Emitter<SubjectState> emit) async {
    final current = state;
    try {
      await _repository.deleteSubject(event.id, examId: event.examId);
      final subjects =
          await _repository.getSubjectsByExam(event.examId);
      emit(SubjectsLoaded(subjects: subjects, examId: event.examId));
    } catch (e) {
      emit(SubjectError(e.toString()));
      if (current is SubjectsLoaded) emit(current);
    }
  }
}
