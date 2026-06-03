import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/util/question_text_format.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/repositories/question_bank_repository.dart';

Future<void> showViewMockTestDialog({
  required BuildContext context,
  required TopicModel topic,
  required TopicTestConfigModel config,
}) {
  return showDialog(
    context: context,
    builder: (_) => _ViewMockTestDialog(topic: topic, config: config),
  );
}

class _ViewMockTestDialog extends StatefulWidget {
  final TopicModel topic;
  final TopicTestConfigModel config;

  const _ViewMockTestDialog({
    required this.topic,
    required this.config,
  });

  @override
  State<_ViewMockTestDialog> createState() => _ViewMockTestDialogState();
}

class _ViewMockTestDialogState extends State<_ViewMockTestDialog> {
  final _repo = GetIt.I<QuestionBankRepository>();
  String _questionText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _repo.listQuestions(topicId: widget.topic.id);
      if (mounted) {
        setState(() {
          _questionText = serializeQuestions(questions.where((q) => q.isActive).toList());
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return AlertDialog(
      title: Text('Mock Test — ${widget.topic.title}'),
      content: SizedBox(
        width: 720,
        child: _loading
            ? const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _detailRow('Status', c.isActive ? 'Active' : 'Inactive'),
                    _detailRow('Questions per test', '${c.numQuestions}'),
                    _detailRow('Duration', '${c.durationMinutes} minutes'),
                    _detailRow('Difficulty filter', c.difficultyFilter),
                    _detailRow('Available questions', '${c.availableQuestionCount}'),
                    const SizedBox(height: 16),
                    Text('Questions', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_questionText.isEmpty)
                      const Text('No active questions for this topic.')
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AdminColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AdminColors.shadow),
                        ),
                        child: SelectableText(
                          _questionText,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: AdminColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
