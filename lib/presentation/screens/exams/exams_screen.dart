import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/exam_model.dart';
import '../../../data/repositories/exam_category_repository.dart';
import '../../blocs/exam/exam_bloc.dart';

class ExamsScreen extends StatefulWidget {
  final bool embedMode;
  const ExamsScreen({super.key, this.embedMode = false});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late final ExamBloc _bloc;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<ExamBloc>()..add(ExamsLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showExamDialog({ExamModel? exam}) async {
    final categories = await GetIt.I<ExamCategoryRepository>().getCategories();
    if (!mounted) return;

    final nameCtrl = TextEditingController(text: exam?.name ?? '');
    final codeCtrl = TextEditingController(text: exam?.code ?? '');
    final descCtrl = TextEditingController(text: exam?.description ?? '');
    final shortCtrl = TextEditingController(text: exam?.shortDescription ?? '');
    final colorCtrl =
        TextEditingController(text: exam?.colorCode ?? '#6C63FF');
    final iconCtrl = TextEditingController(text: exam?.iconUrl ?? '');
    final diffCtrl = TextEditingController(text: exam?.difficultyLevel ?? '');
    int? categoryId = exam?.categoryId;
    bool featured = exam?.featured ?? false;
    bool popular = exam?.popular ?? false;
    bool isActive = exam?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
        title: Text(exam == null ? 'Add Exam' : 'Edit Exam'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                  controller: shortCtrl,
                  decoration: const InputDecoration(labelText: 'Short description'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Full description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setLocal(() => categoryId = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: iconCtrl,
                  decoration: const InputDecoration(labelText: 'Icon URL'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: diffCtrl,
                  decoration: const InputDecoration(labelText: 'Difficulty level'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: colorCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Color (#hex)'),
                ),
                SwitchListTile(
                  title: const Text('Featured'),
                  value: featured,
                  onChanged: (v) => setLocal(() => featured = v),
                ),
                SwitchListTile(
                  title: const Text('Popular'),
                  value: popular,
                  onChanged: (v) => setLocal(() => popular = v),
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (v) => setLocal(() => isActive = v),
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
                'name': nameCtrl.text.trim(),
                'code': codeCtrl.text.trim().toUpperCase(),
                'shortDescription': shortCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                if (categoryId != null) 'categoryId': categoryId,
                'iconUrl': iconCtrl.text.trim().isEmpty ? null : iconCtrl.text.trim(),
                'difficultyLevel': diffCtrl.text.trim().isEmpty ? null : diffCtrl.text.trim(),
                'colorCode': colorCtrl.text.trim(),
                'featured': featured,
                'popular': popular,
                'isActive': isActive,
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
      child: BlocListener<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AdminColors.error,
              ),
            );
            // Reload the list so the error state doesn't clear the screen
            _bloc.add(ExamsLoadRequested());
          }
        },
        child: Scaffold(
          appBar: widget.embedMode
              ? null
              : AppBar(
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
            buildWhen: (prev, curr) => curr is! ExamError,
            builder: (context, state) {
              if (state is ExamLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is! ExamsLoaded) {
                return const SizedBox.shrink();
              }
              final query = _searchQuery.trim().toLowerCase();
              final exams = state.exams.where((exam) {
                if (query.isEmpty) return true;
                return exam.name.toLowerCase().contains(query) ||
                    exam.code.toLowerCase().contains(query);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search exams by name or code',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: exams.isEmpty
                        ? const Center(
                            child: Text('No exams match your search.'),
                          )
                        : ListView.separated(
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
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AdminColors.shadow,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AdminColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book_rounded,
                                      color: AdminColors.primary,
                                    ),
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
                                    icon: const Icon(Icons.list_alt_rounded),
                                    tooltip: 'Manage Subjects',
                                    onPressed: () => context.go(
                                        '/exams/${exam.id}/subjects',
                                        extra: exam.name),
                                    color: AdminColors.primary,
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
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
