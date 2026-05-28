import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../data/repositories/subject_repository.dart';
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
  late final SubjectRepository _subjectRepository;
  late final ExamRepository _examRepository;

  @override
  void initState() {
    super.initState();
    _subjectRepository = GetIt.I<SubjectRepository>();
    _examRepository = GetIt.I<ExamRepository>();
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

  Future<void> _showCloneSubjectDialog() async {
    final screenContext = context;
    try {
      final exams = await _examRepository.getExams();
      final sourceExams = exams.where((e) => e.id != widget.examId).toList();
      if (!mounted) return;

      if (sourceExams.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other exams found to clone from.')),
        );
        return;
      }

      final orderCtrl = TextEditingController();
      final currentState = _bloc.state;
      final suggestedOrder = currentState is SubjectsLoaded
          ? currentState.subjects.length + 1
          : 1;
      orderCtrl.text = suggestedOrder.toString();

      await showDialog(
        context: context,
        builder: (ctx) {
          ExamModel selectedExam = sourceExams.first;
          List<SubjectModel> sourceSubjects = [];
          SubjectModel? selectedSubject;
          bool loadingSubjects = true;
          String? loadError;

          Future<void> loadSubjects(StateSetter setDialogState) async {
            setDialogState(() {
              loadingSubjects = true;
              loadError = null;
            });
            try {
              final subjects =
                  await _subjectRepository.getSubjectsByExam(selectedExam.id);
              setDialogState(() {
                sourceSubjects = subjects;
                selectedSubject =
                    subjects.isNotEmpty ? subjects.first : null;
                loadingSubjects = false;
              });
            } catch (error) {
              setDialogState(() {
                loadingSubjects = false;
                loadError = error.toString();
              });
            }
          }

          return StatefulBuilder(
            builder: (dialogStateContext, setDialogState) {
              if (loadingSubjects && sourceSubjects.isEmpty && loadError == null) {
                Future.microtask(() => loadSubjects(setDialogState));
              }

              return AlertDialog(
                title: const Text('Clone Subject From Another Exam'),
                content: SizedBox(
                  width: 460,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<ExamModel>(
                        value: selectedExam,
                        decoration: const InputDecoration(
                          labelText: 'Source Exam',
                        ),
                        items: sourceExams
                            .map((exam) => DropdownMenuItem<ExamModel>(
                                  value: exam,
                                  child: Text(exam.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          selectedExam = value;
                          sourceSubjects = [];
                          selectedSubject = null;
                          loadSubjects(setDialogState);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (loadingSubjects)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        )
                      else if (loadError != null)
                        Text(
                          'Could not load subjects: $loadError',
                          style: TextStyle(
                              color: Theme.of(dialogStateContext)
                                  .colorScheme
                                  .error),
                        )
                      else if (sourceSubjects.isEmpty)
                        const Text('No subjects found in selected source exam.')
                      else
                        DropdownButtonFormField<SubjectModel>(
                          value: selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Source Subject',
                          ),
                          items: sourceSubjects
                              .map((subject) => DropdownMenuItem<SubjectModel>(
                                    value: subject,
                                    child: Text(subject.name),
                                  ))
                              .toList(),
                          onChanged: (value) => setDialogState(() {
                            selectedSubject = value;
                          }),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: orderCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Display order in current exam',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This clones subject metadata and all chapters/topics into the current exam.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  FilledButton.icon(
                    onPressed: (loadingSubjects || selectedSubject == null)
                        ? null
                        : () async {
                            final sourceSubject = selectedSubject!;
                            try {
                              final displayOrder =
                                  int.tryParse(orderCtrl.text.trim());
                              await _subjectRepository.cloneSubject(
                                sourceSubjectId: sourceSubject.id,
                                targetExamId: widget.examId,
                                displayOrder: displayOrder,
                              );
                              if (!screenContext.mounted) return;
                              Navigator.of(screenContext).pop();
                              _bloc.add(SubjectsLoadRequested(widget.examId));
                              ScaffoldMessenger.of(screenContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cloned "${sourceSubject.name}" successfully.',
                                  ),
                                ),
                              );
                            } catch (error) {
                              if (!screenContext.mounted) return;
                              ScaffoldMessenger.of(screenContext).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                  backgroundColor: AdminColors.error,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Clone Subject'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      if (!screenContext.mounted) return;
      ScaffoldMessenger.of(screenContext).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AdminColors.error,
        ),
      );
    }
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
              onPressed: _showCloneSubjectDialog,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Clone Subject'),
            ),
            const SizedBox(width: 8),
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
                        color: AdminColors.primary.withValues(alpha: 0.3)),
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
                    boxShadow: const [
                      BoxShadow(
                        color: AdminColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.15),
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
                      TextButton.icon(
                        icon: const Icon(Icons.menu_book_rounded, size: 18),
                        label: const Text('Chapters'),
                        onPressed: () => context.go(
                          '/exams/${widget.examId}/subjects/${sub.id}/chapters',
                          extra: sub.name,
                        ),
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
