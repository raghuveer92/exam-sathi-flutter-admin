import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../blocs/exam/exam_bloc.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late final ExamBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<ExamBloc>()..add(ExamsLoadRequested());
  }

  void _showExamDialog({ExamModel? exam}) {
    final nameCtrl = TextEditingController(text: exam?.name ?? '');
    final codeCtrl = TextEditingController(text: exam?.code ?? '');
    final descCtrl = TextEditingController(text: exam?.description ?? '');
    final colorCtrl =
        TextEditingController(text: exam?.colorCode ?? '#6C63FF');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exam == null ? 'Add Exam' : 'Edit Exam'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: colorCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Color (#hex)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'name': nameCtrl.text.trim(),
                'code': codeCtrl.text.trim().toUpperCase(),
                'description': descCtrl.text.trim(),
                'colorCode': colorCtrl.text.trim(),
                'isActive': true,
              };
              if (exam == null) {
                _bloc.add(ExamCreateRequested(data));
              } else {
                _bloc.add(ExamUpdateRequested(id: exam.id, data: data));
              }
              Navigator.pop(ctx);
            },
            child: Text(exam == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ExamModel exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam'),
        content:
            Text('Delete "${exam.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error),
            onPressed: () {
              _bloc.add(ExamDeleteRequested(exam.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exams'),
          actions: [
            FilledButton.icon(
              onPressed: () => _showExamDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Exam'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: BlocBuilder<ExamBloc, ExamState>(
          builder: (context, state) {
            if (state is ExamLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExamError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is! ExamsLoaded) {
              return const SizedBox.shrink();
            }
            final exams = state.exams;
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: exams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final exam = exams[i];
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AdminColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AdminColors.shadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AdminColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: AdminColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.name,
                              style:
                                  Theme.of(context).textTheme.titleLarge),
                          Text(
                            '${exam.code} · ${exam.subjectCount} subjects',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showExamDialog(exam: exam),
                      color: AdminColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(exam),
                      color: AdminColors.error,
                    ),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
