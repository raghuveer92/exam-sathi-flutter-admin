import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/subject_model.dart';
import '../../blocs/subject/subject_bloc.dart';

class SubjectsScreen extends StatefulWidget {
  final int examId;
  final String examName;

  const SubjectsScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late final SubjectBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<SubjectBloc>()
      ..add(SubjectsLoadRequested(widget.examId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _showSubjectDialog({SubjectModel? subject}) {
    final nameCtrl =
        TextEditingController(text: subject?.name ?? '');
    final descCtrl =
        TextEditingController(text: subject?.description ?? '');
    final iconCtrl = TextEditingController(
        text: subject?.iconName ?? 'menu_book');
    final colorCtrl = TextEditingController(
        text: subject?.colorCode ?? '#6C63FF');
    final orderCtrl = TextEditingController(
        text: (subject?.displayOrder ?? 0).toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subject == null ? 'Add Subject' : 'Edit Subject'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Name *'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: iconCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Icon name *',
                      hintText: 'e.g. calculate, science, menu_book',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: colorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Color (#hex) *',
                      hintText: '#1565C0',
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: orderCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Display order'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
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
                'examId': widget.examId,
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'iconName': iconCtrl.text.trim(),
                'colorCode': colorCtrl.text.trim(),
                'displayOrder':
                    int.tryParse(orderCtrl.text.trim()) ?? 0,
                'isActive': true,
              };
              if (subject == null) {
                _bloc.add(SubjectCreateRequested(data));
              } else {
                _bloc.add(SubjectUpdateRequested(
                    id: subject.id, data: data));
              }
              Navigator.pop(ctx);
            },
            child: Text(subject == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject'),
        content:
            Text('Delete "${subject.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.error),
            onPressed: () {
              _bloc.add(SubjectDeleteRequested(
                  id: subject.id, examId: widget.examId));
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.white)),
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
          title: Text('${widget.examName} — Subjects'),
          actions: [
            FilledButton.icon(
              onPressed: () => _showSubjectDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: BlocBuilder<SubjectBloc, SubjectState>(
          builder: (context, state) {
            if (state is SubjectLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SubjectError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _bloc
                          .add(SubjectsLoadRequested(widget.examId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is! SubjectsLoaded) {
              return const SizedBox.shrink();
            }
            final subjects = state.subjects;
            if (subjects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.subject_rounded,
                        size: 64,
                        color: AdminColors.primary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No subjects yet',
                        style:
                            Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                        'Tap "Add Subject" to create the first one.'),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: subjects.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final sub = subjects[i];
                Color cardColor;
                try {
                  final hex =
                      sub.colorCode.replaceFirst('#', '');
                  cardColor = Color(int.parse('FF$hex', radix: 16));
                } catch (_) {
                  cardColor = AdminColors.primary;
                }
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
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.subject_rounded,
                            color: cardColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(sub.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium),
                            Text(
                              '${sub.topicCount} topics · order ${sub.displayOrder}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            _showSubjectDialog(subject: sub),
                        color: AdminColors.primary,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(sub),
                        color: AdminColors.error,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
