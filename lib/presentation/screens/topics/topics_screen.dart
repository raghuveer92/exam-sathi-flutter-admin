import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/repositories/syllabus_repository.dart';
import 'topic_bulk_upload_dialog.dart';

class TopicsScreen extends StatefulWidget {
  final int chapterId;
  final String chapterTitle;

  const TopicsScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late final SyllabusRepository _repo;
  List<TopicModel> _topics = [];
  bool _loading = true;
  String? _error;

  static const _difficulties = ['EASY', 'MEDIUM', 'HARD'];

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<SyllabusRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final topics = await _repo.getTopicsByChapter(widget.chapterId);
      setState(() { _topics = topics; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _showBulkUploadDialog() async {
    final topics = await showTopicBulkUploadDialog(
      context: context,
      chapterId: widget.chapterId,
      startingOrderIndex: _topics.length + 1,
    );
    if (!mounted || topics == null || topics.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final created = await _repo.bulkCreateTopics(topics);
      await _load();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploaded ${created.length} topics successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AdminColors.error,
        ),
      );
    }
  }

  void _showDialog({TopicModel? topic}) {
    final titleCtrl = TextEditingController(text: topic?.title ?? '');
    final descCtrl = TextEditingController(text: topic?.description ?? '');
    final hoursCtrl = TextEditingController(
        text: (topic?.estimatedHours ?? 1.0).toString());
    final orderCtrl = TextEditingController(
        text: (topic?.orderIndex ?? _topics.length + 1).toString());
    String selectedDifficulty = topic?.difficultyLevel ?? 'MEDIUM';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(topic == null ? 'Add Topic' : 'Edit Topic'),
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
                      controller: hoursCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Estimated Hours',
                          hintText: 'e.g. 2.5'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(labelText: 'Difficulty'),
                      items: _difficulties
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedDifficulty = v!),
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
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                final data = {
                  'chapterId': widget.chapterId,
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'estimatedHours':
                      double.tryParse(hoursCtrl.text.trim()) ?? 1.0,
                  'difficultyLevel': selectedDifficulty,
                  'orderIndex': int.tryParse(orderCtrl.text.trim()) ?? 0,
                  'isActive': true,
                };
                try {
                  if (topic == null) {
                    await _repo.createTopic(data);
                  } else {
                    await _repo.updateTopic(topic.id, data);
                  }
                  _load();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: AdminColors.error),
                    );
                  }
                }
              },
              child: Text(topic == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(TopicModel topic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text('Delete "${topic.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _repo.deleteTopic(topic.id);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AdminColors.error),
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

  Color _difficultyColor(String d) {
    switch (d) {
      case 'EASY':
        return const Color(0xFF43A047);
      case 'HARD':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFFFB8C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chapterTitle} — Topics'),
        actions: [
          FilledButton.icon(
            onPressed: _loading ? null : _showBulkUploadDialog,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Bulk Upload'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _loading ? null : () => _showDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Topic'),
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
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _topics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.topic_rounded,
                              size: 64,
                              color: AdminColors.primary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('No topics yet',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          const Text('Tap "Add Topic" to create the first one.'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _topics.length + 1,
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
                                    'These topics are part of the shared syllabus. Editing or deleting one updates it everywhere this subject is used.',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final t = _topics[i - 1];
                        final diffColor = _difficultyColor(t.difficultyLevel);
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
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    t.difficultyLevel[0],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: diffColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Row(
                                      children: [
                                        Text(
                                          '${t.estimatedHours}h  ·  ',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: diffColor.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            t.difficultyLevel,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: diffColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showDialog(topic: t),
                                color: AdminColors.primary,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(t),
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
