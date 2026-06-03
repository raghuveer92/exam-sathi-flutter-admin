import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/admin/admin_bloc.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late final AdminBloc _bloc;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<AdminBloc>()..add(AdminStudentsRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    _bloc.add(AdminStudentsRequested(query: _searchCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Students')),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextFormField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search students…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: _search,
                  ),
                ),
                onFieldSubmitted: (_) => _search(),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AdminError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is! AdminStudentsLoaded) {
                    return const SizedBox.shrink();
                  }
                  final students = state.students;
                  if (students.isEmpty) {
                    return const Center(child: Text('No students found'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: students.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) =>
                        _StudentTile(student: students[i], bloc: _bloc),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final AdminUserModel student;
  final AdminBloc bloc;

  const _StudentTile({required this.student, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AdminColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AdminColors.primary.withValues(alpha: 0.12),
          child: Text(
            student.firstName[0].toUpperCase(),
            style: const TextStyle(
                color: AdminColors.primary, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.fullName,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(student.email,
                  style: Theme.of(context).textTheme.bodyMedium),
              if (student.selectedExamName != null)
                Text(student.selectedExamName!,
                    style: const TextStyle(
                        color: AdminColors.primary, fontSize: 11)),
            ],
          ),
        ),
        Text(
          '🔥 ${student.studyStreakDays}d',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 8),
        Switch(
          value: student.isActive,
          activeColor: AdminColors.success,
          onChanged: (val) {
            bloc.add(AdminToggleStudentStatus(
                userId: student.id, isActive: val));
          },
        ),
      ]),
    );
  }
}
