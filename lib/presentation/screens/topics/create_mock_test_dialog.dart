import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_extra.dart';
import '../../../core/util/question_text_format.dart';
import '../../../data/models/question_model.dart';
import '../../../data/models/topic_model.dart';
import '../../../data/repositories/question_bank_repository.dart';

Future<bool?> showCreateMockTestDialog({
  required BuildContext context,
  required int examId,
  required int subjectId,
  required int chapterId,
  required String examName,
  required String subjectName,
  required String chapterTitle,
  required TopicModel topic,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => _CreateMockTestDialog(
      examId: examId,
      subjectId: subjectId,
      chapterId: chapterId,
      examName: examName,
      subjectName: subjectName,
      chapterTitle: chapterTitle,
      topic: topic,
    ),
  );
}

class _CreateMockTestDialog extends StatefulWidget {
  final int examId;
  final int subjectId;
  final int chapterId;
  final String examName;
  final String subjectName;
  final String chapterTitle;
  final TopicModel topic;

  const _CreateMockTestDialog({
    required this.examId,
    required this.subjectId,
    required this.chapterId,
    required this.examName,
    required this.subjectName,
    required this.chapterTitle,
    required this.topic,
  });

  @override
  State<_CreateMockTestDialog> createState() => _CreateMockTestDialogState();
}

class _CreateMockTestDialogState extends State<_CreateMockTestDialog> {
  final _repo = GetIt.I<QuestionBankRepository>();
  final _numCtrl = TextEditingController(text: '10');
  final _durCtrl = TextEditingController(text: '15');
  final _questionsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _difficulty = 'ALL';
  bool _isActive = true;
  bool _loadingConfig = true;
  bool _saving = false;
  List<String> _validationErrors = [];
  TopicTestConfigModel? _existing;

  static const _difficulties = ['ALL', 'EASY', 'MEDIUM', 'HARD'];

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final config = await _repo.getTopicTestByTopic(widget.topic.id);
      final questions = await _repo.listQuestions(topicId: widget.topic.id);
      if (!mounted) return;
      final activeQuestions = questions.where((q) => q.isActive).toList();
      setState(() {
        _existing = config?.isConfigured == true ? config : null;
        if (_existing != null) {
          _numCtrl.text = _existing!.numQuestions.toString();
          _durCtrl.text = _existing!.durationMinutes.toString();
          _difficulty = _existing!.difficultyFilter;
          _isActive = _existing!.isActive;
        }
        if (activeQuestions.isNotEmpty) {
          _questionsCtrl.text = serializeQuestions(activeQuestions);
        }
        _loadingConfig = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingConfig = false);
    }
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _durCtrl.dispose();
    _questionsCtrl.dispose();
    super.dispose();
  }

  void _validateQuestions() {
    setState(() {
      _validationErrors = validateQuestionText(_questionsCtrl.text).errors;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = _existing?.isConfigured == true;
    final rawQuestionText = _questionsCtrl.text;
    final clearingAllQuestions = isQuestionTextEffectivelyEmpty(rawQuestionText);
    if (!isEdit && clearingAllQuestions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paste questions to create a mock test.'),
          backgroundColor: AdminColors.error,
        ),
      );
      return;
    }

    if (!clearingAllQuestions) {
      final validation = validateQuestionText(rawQuestionText);
      if (!validation.isValid) {
        setState(() => _validationErrors = validation.errors);
        return;
      }
    } else if (isEdit) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remove all questions?'),
          content: const Text(
            'The question editor is empty. Saving will remove all questions for this topic.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove all'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      BulkQuestionImportResult? importResult;
      if (isEdit || !clearingAllQuestions) {
        importResult = await _repo.replaceTopicQuestions(
          widget.topic.id,
          widget.examId,
          clearingAllQuestions ? '' : rawQuestionText.trim(),
        );
      }

      await _repo.saveTopicTest({
        'topicId': widget.topic.id,
        'numQuestions': int.parse(_numCtrl.text.trim()),
        'durationMinutes': int.parse(_durCtrl.text.trim()),
        'difficultyFilter': _difficulty,
        'isActive': _isActive,
      });

      final importMsg = importResult == null
          ? ''
          : ' ${importResult.imported} question(s) saved'
              '${importResult.failed > 0 ? ' (${importResult.failed} errors)' : ''}.';

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);

      if (importResult != null && importResult.errors.isNotEmpty) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Import warnings'),
            content: SingleChildScrollView(
              child: Text(importResult!.errors.take(8).join('\n')),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      nav.pop(true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Mock test saved for "${widget.topic.title}".$importMsg',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage(e)), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final config = _existing;
    if (config?.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Mock Test'),
        content: const Text(
          'Delete this mock test and its questions for this topic?\n\n'
          'Questions used in past student attempts are kept for history but deactivated.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await _repo.deleteTopicTest(config!.id!);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text('Mock test deleted for "${widget.topic.title}".')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage(e)), backgroundColor: AdminColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existing?.isConfigured == true;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Mock Test' : 'Create Mock Test'),
      content: SizedBox(
        width: 760,
        child: _loadingConfig
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.topic.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${widget.examName} · ${widget.subjectName} · ${widget.chapterTitle}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 24),
                      Text('Test settings', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numCtrl,
                              decoration: const InputDecoration(labelText: 'Number of questions'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? '');
                                if (n == null || n < 1) return 'Enter at least 1';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _durCtrl,
                              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? '');
                                if (n == null || n < 1) return 'Enter at least 1';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _difficulty,
                        decoration: const InputDecoration(labelText: 'Difficulty filter'),
                        items: _difficulties
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) => setState(() => _difficulty = v ?? 'ALL'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        subtitle: const Text('Students can start this mock test'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Text('Paste Questions', style: Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() {
                              _questionsCtrl.text = questionTextTemplate;
                              _validationErrors = [];
                            }),
                            child: const Text('Load example'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEdit
                            ? 'Edit questions below. Saving replaces all questions for this topic. Separate questions with --- on its own line.'
                            : 'Paste questions using the text format below. Separate questions with --- on its own line.',
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _questionsCtrl,
                        maxLines: 18,
                        onChanged: (_) {
                          if (_validationErrors.isNotEmpty) {
                            setState(() => _validationErrors = []);
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Paste Questions',
                          hintText: 'QUESTION: ...\nTYPE: SINGLE_CORRECT\nOPTION_A: ...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: _validateQuestions,
                          child: const Text('Validate format'),
                        ),
                      ),
                      if (_validationErrors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AdminColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AdminColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _validationErrors
                                .map((e) => Text(e, style: const TextStyle(color: AdminColors.error)))
                                .toList(),
                          ),
                        ),
                      ],
                      if (_existing?.isConfigured == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${_existing!.availableQuestionCount} active questions in bank',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        if (isEdit)
          TextButton(
            onPressed: _saving ? null : _delete,
            child: const Text('Delete', style: TextStyle(color: AdminColors.error)),
          ),
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving || _loadingConfig ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
