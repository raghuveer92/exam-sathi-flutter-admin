import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/repositories/syllabus_repository.dart';

class ChaptersScreen extends StatefulWidget {
  final int examId;
  final int subjectId;
  final String examName;
  final String subjectName;

  const ChaptersScreen({
    super.key,
    required this.examId,
    required this.subjectId,
    required this.examName,
    required this.subjectName,
  });

  @override
  State<ChaptersScreen> createState() => _ChaptersScreenState();
}

class _ChaptersScreenState extends State<ChaptersScreen> {
  late final SyllabusRepository _repo;
  List<ChapterModel> _chapters = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<SyllabusRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final chapters = await _repo.getChaptersBySubject(widget.subjectId);
      setState(() { _chapters = chapters; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _showDialog({ChapterModel? chapter}) {
    final titleCtrl = TextEditingController(text: chapter?.title ?? '');
    final descCtrl = TextEditingController(text: chapter?.description ?? '');
    final orderCtrl = TextEditingController(text: (chapter?.orderIndex ?? _chapters.length + 1).toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(chapter == null ? 'Add Chapter' : 'Edit Chapter'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: orderCtrl,
                    decoration: const InputDecoration(labelText: 'Order Index'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final data = {
                'subjectId': widget.subjectId,
                'title': titleCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'orderIndex': int.tryParse(orderCtrl.text.trim()) ?? 0,
                'isActive': true,
              };
              try {
                if (chapter == null) {
                  await _repo.createChapter(data);
                } else {
                  await _repo.updateChapter(chapter.id, data);
                }
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AdminColors.error),
                  );
                }
              }
            },
            child: Text(chapter == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ChapterModel chapter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Chapter'),
        content: Text('Delete "${chapter.title}"? All topics inside will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repo.deleteChapter(chapter.id);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AdminColors.error),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} — Chapters'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Chapter'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _chapters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 64, color: AdminColors.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No chapters yet', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          const Text('Tap "Add Chapter" to create the first one.'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _chapters.length + 1,
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
                                    'These chapters belong to a shared subject. Any create, edit, or delete action here affects every exam linked to this subject.',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final ch = _chapters[i - 1];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AdminColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: AdminColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AdminColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text('${ch.orderIndex}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ch.title, style: Theme.of(context).textTheme.titleMedium),
                                    Text('${ch.topicCount} topics',
                                        style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.list_alt_rounded, size: 18),
                                label: const Text('Topics'),
                                onPressed: () => context.go(
                                  '/exams/${widget.examId}/subjects/${widget.subjectId}/chapters/${ch.id}/topics',
                                  extra: {
                                    'chapterTitle': ch.title,
                                    'examName': widget.examName,
                                    'subjectName': widget.subjectName,
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showDialog(chapter: ch),
                                color: AdminColors.primary,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(ch),
                                color: AdminColors.error,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
