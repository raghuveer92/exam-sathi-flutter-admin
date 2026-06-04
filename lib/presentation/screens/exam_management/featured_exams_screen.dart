import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../data/models/exam_model.dart';
import '../../../data/repositories/exam_repository.dart';

class FeaturedExamsScreen extends StatefulWidget {
  const FeaturedExamsScreen({super.key});

  @override
  State<FeaturedExamsScreen> createState() => _FeaturedExamsScreenState();
}

class _FeaturedExamsScreenState extends State<FeaturedExamsScreen> {
  final _repo = GetIt.I<ExamRepository>();
  List<ExamModel> _exams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final exams = await _repo.getExams();
      if (!mounted) return;
      setState(() {
        _exams = exams;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggle(ExamModel exam, {bool? featured, bool? popular}) async {
    await _repo.updateExam(exam.id, {
      ...exam.toJson(),
      if (featured != null) 'featured': featured,
      if (popular != null) 'popular': popular,
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Featured & Popular Exams')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exams.length,
              itemBuilder: (_, i) {
                final e = _exams[i];
                return Card(
                  child: ListTile(
                    title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(e.shortDescription ?? e.description ?? e.code),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterChip(
                          label: const Text('Featured'),
                          selected: e.featured,
                          onSelected: (v) => _toggle(e, featured: v),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Popular'),
                          selected: e.popular,
                          onSelected: (v) => _toggle(e, popular: v),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
