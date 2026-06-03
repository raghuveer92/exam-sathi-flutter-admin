import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_subject_group_model.dart';
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
  List<ExamSubjectGroupModel> _groups = const [];
  bool _groupsLoading = true;

  @override
  void initState() {
    super.initState();
    _subjectRepository = GetIt.I<SubjectRepository>();
    _examRepository = GetIt.I<ExamRepository>();
    _refreshGroups(showErrors: false);
    _bloc = GetIt.I<SubjectBloc>()
      ..add(SubjectsLoadRequested(widget.examId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _refreshGroups({bool showErrors = true}) async {
    try {
      final groups = await _subjectRepository.getSubjectGroupsByExam(widget.examId);
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _groupsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _groupsLoading = false);
      if (showErrors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load subject groups: $error'),
            backgroundColor: AdminColors.error,
          ),
        );
      }
    }
  }

  String _selectionRuleLabel(ExamSubjectGroupModel group) {
    if (!group.isOptional) {
      return 'Mandatory';
    }
    if (group.maxSelection <= 1) {
      return group.minSelection > 0 ? 'Pick 1 subject' : 'Optional single pick';
    }
    return 'Pick ${group.minSelection}-${group.maxSelection} subjects';
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
    int? selectedGroupId = subject?.groupId ?? _groups.firstOrNull?.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
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
                    DropdownButtonFormField<int>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(labelText: 'Subject Group'),
                      items: _groups
                          .map((group) => DropdownMenuItem<int>(
                                value: group.id,
                                child: Text(group.groupName),
                              ))
                          .toList(),
                      onChanged: (value) => setDialogState(() => selectedGroupId = value),
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
                  'groupId': selectedGroupId,
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
      ),
    );
  }

  Future<void> _showGroupDialog({ExamSubjectGroupModel? group}) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: group?.groupName ?? '');
    final minCtrl = TextEditingController(text: (group?.minSelection ?? 0).toString());
    final maxCtrl = TextEditingController(text: (group?.maxSelection ?? 0).toString());
    final orderCtrl = TextEditingController(text: (group?.displayOrder ?? _groups.length).toString());
    var isOptional = group?.isOptional ?? false;
    final currentSubjects = _bloc.state is SubjectsLoaded
        ? (_bloc.state as SubjectsLoaded).subjects
        : <SubjectModel>[];
    final selectedSubjectIds = <int>{
      ...?group?.subjects.map((subject) => subject.id),
    };

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(group == null ? 'Add Subject Group' : 'Edit Subject Group'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Group name *'),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Optional Group'),
                      subtitle: const Text('Mandatory groups stay visible for every student.'),
                      value: isOptional,
                      onChanged: (value) => setDialogState(() => isOptional = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: minCtrl,
                            decoration: const InputDecoration(labelText: 'Min selection'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: maxCtrl,
                            decoration: const InputDecoration(labelText: 'Max selection'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: orderCtrl,
                      decoration: const InputDecoration(labelText: 'Display order'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Assigned Subjects',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (currentSubjects.isEmpty)
                      const Text('Create or add a subject first, then assign it here.')
                    else
                      ...currentSubjects.map((subject) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selectedSubjectIds.contains(subject.id),
                            title: Text(subject.name),
                            subtitle: subject.groupName == null
                                ? null
                                : Text('Currently in ${subject.groupName}'),
                            onChanged: (value) {
                              setDialogState(() {
                                if (value ?? false) {
                                  selectedSubjectIds.add(subject.id);
                                } else {
                                  selectedSubjectIds.remove(subject.id);
                                }
                              });
                            },
                          )),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'examId': widget.examId,
                  'groupName': nameCtrl.text.trim(),
                  'isOptional': isOptional,
                  'minSelection': int.tryParse(minCtrl.text.trim()) ?? 0,
                  'maxSelection': int.tryParse(maxCtrl.text.trim()) ?? 0,
                  'displayOrder': int.tryParse(orderCtrl.text.trim()) ?? 0,
                  'subjectIds': selectedSubjectIds.toList(),
                };
                try {
                  if (group == null) {
                    await _subjectRepository.createSubjectGroup(data);
                  } else {
                    await _subjectRepository.updateSubjectGroup(group.id, data);
                  }
                  if (!ctx.mounted || !mounted) return;
                  Navigator.of(ctx).pop();
                  await _refreshGroups();
                  _bloc.add(SubjectsLoadRequested(widget.examId));
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                      backgroundColor: AdminColors.error,
                    ),
                  );
                }
              },
              child: Text(group == null ? 'Create Group' : 'Update Group'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGroup(ExamSubjectGroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subject Group'),
        content: Text('Delete "${group.groupName}"? Subjects will fall back to the exam\'s mandatory group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _subjectRepository.deleteSubjectGroup(group.id);
                if (!ctx.mounted || !mounted) return;
                Navigator.of(ctx).pop();
                await _refreshGroups();
                _bloc.add(SubjectsLoadRequested(widget.examId));
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                    backgroundColor: AdminColors.error,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AdminColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Subject From Exam'),
        content: Text(
          'Remove "${subject.name}" from ${widget.examName}? '
          'If no other exam uses it, the shared subject and its syllabus will also be deleted.',
        ),
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
          int selectedExamId = sourceExams.first.id;
          List<SubjectModel> sourceSubjects = [];
          int? selectedSubjectId;
          int? selectedGroupId = _groups.firstOrNull?.id;
          bool loadingSubjects = true;
          String? loadError;
          bool initialLoadTriggered = false;
          int loadRequestId = 0;

          Future<void> loadSubjects(StateSetter setDialogState) async {
            final requestId = ++loadRequestId;
            setDialogState(() {
              loadingSubjects = true;
              loadError = null;
            });
            try {
              final subjects =
                  await _subjectRepository.getSubjectsByExam(selectedExamId);
              if (requestId != loadRequestId) {
                return;
              }
              setDialogState(() {
                sourceSubjects = subjects;
                selectedSubjectId =
                    subjects.isNotEmpty ? subjects.first.id : null;
                loadingSubjects = false;
              });
            } catch (error) {
              if (requestId != loadRequestId) {
                return;
              }
              setDialogState(() {
                loadingSubjects = false;
                loadError = error.toString();
              });
            }
          }

          return StatefulBuilder(
            builder: (dialogStateContext, setDialogState) {
              if (!initialLoadTriggered) {
                initialLoadTriggered = true;
                Future.microtask(() => loadSubjects(setDialogState));
              }

              return AlertDialog(
                title: const Text('Add Existing Subject'),
                content: SizedBox(
                  width: 460,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedExamId,
                        decoration: const InputDecoration(
                          labelText: 'Source Exam',
                        ),
                        items: sourceExams
                            .map((exam) => DropdownMenuItem<int>(
                                  value: exam.id,
                                  child: Text(exam.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedExamId = value;
                            sourceSubjects = [];
                            selectedSubjectId = null;
                            loadError = null;
                          });
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
                        DropdownButtonFormField<int>(
                          value: selectedSubjectId,
                          decoration: const InputDecoration(
                            labelText: 'Source Subject',
                          ),
                          items: sourceSubjects
                              .map((subject) => DropdownMenuItem<int>(
                                    value: subject.id,
                                    child: Text(subject.name),
                                  ))
                              .toList(),
                          onChanged: (value) => setDialogState(() {
                            selectedSubjectId = value;
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
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Target Group in Current Exam',
                        ),
                        items: _groups
                            .map((group) => DropdownMenuItem<int>(
                                  value: group.id,
                                  child: Text(group.groupName),
                                ))
                            .toList(),
                        onChanged: (value) => setDialogState(() {
                          selectedGroupId = value;
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This links the selected shared subject into ${widget.examName}. '
                        'Its chapters and topics remain shared across every linked exam.',
                        style: const TextStyle(fontSize: 12),
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
                    onPressed: (loadingSubjects || selectedSubjectId == null)
                        ? null
                        : () async {
                            final sourceSubject = sourceSubjects.firstWhere(
                              (subject) => subject.id == selectedSubjectId,
                            );
                            try {
                              final displayOrder =
                                  int.tryParse(orderCtrl.text.trim());
                              await _subjectRepository.cloneSubject(
                                sourceSubjectId: sourceSubject.id,
                                targetExamId: widget.examId,
                                displayOrder: displayOrder,
                                groupId: selectedGroupId,
                              );
                              if (!screenContext.mounted) return;
                              Navigator.of(screenContext).pop();
                              _bloc.add(SubjectsLoadRequested(widget.examId));
                              ScaffoldMessenger.of(screenContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added shared subject "${sourceSubject.name}" to ${widget.examName}.',
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
                    label: const Text('Add Existing Subject'),
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
      child: BlocListener<SubjectBloc, SubjectState>(
        listener: (context, state) {
          if (state is SubjectsLoaded) {
            _refreshGroups(showErrors: false);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.examName} — Subjects'),
            actions: [
              FilledButton.icon(
                onPressed: () => _showGroupDialog(),
                icon: const Icon(Icons.layers_outlined),
                label: const Text('Add Group'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _showCloneSubjectDialog,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Add Existing Subject'),
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
                        'Tap "Add Subject" to create the first one or add an existing shared subject.'),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: subjects.length + 2,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AdminColors.primary.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Subjects are shared globally. Removing one unlinks it from this exam first, while chapter and topic edits update the shared syllabus for every exam using it.',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (i == 1) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: AdminColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Subject Groups',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showGroupDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Create Group'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_groupsLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _groups.map((group) {
                              return Container(
                                width: 300,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: group.isOptional
                                        ? AdminColors.primary.withValues(alpha: 0.25)
                                        : const Color(0xFFD8DDEA),
                                  ),
                                  color: group.isOptional
                                      ? AdminColors.primary.withValues(alpha: 0.05)
                                      : Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            group.groupName,
                                            style: const TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _showGroupDialog(group: group),
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                        ),
                                        IconButton(
                                          onPressed: group.isOptional ? () => _confirmDeleteGroup(group) : null,
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          color: AdminColors.error,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _selectionRuleLabel(group),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: group.subjects.isEmpty
                                          ? const [Text('No subjects assigned yet')]
                                          : group.subjects
                                              .map((subject) => Chip(label: Text(subject.name)))
                                              .toList(),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  );
                }

                final sub = subjects[i - 2];
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
                            if (sub.groupName != null)
                              Text(
                                '${sub.groupName}${sub.groupOptional == true ? ' · Optional' : ' · Mandatory'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            Text(
                              'Shared syllabus',
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
                          extra: {
                            'subjectName': sub.name,
                            'examName': widget.examName,
                          },
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
      ),
    );
  }
}
