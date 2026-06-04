import 'package:flutter/material.dart';

import '../exams/exams_screen.dart';

/// Roadmap configuration — opens exam list; drill into subjects/chapters/topics.
class ExamRoadmapsScreen extends StatelessWidget {
  const ExamRoadmapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Roadmaps')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Select an exam to configure subjects, chapters, topics, and default study content.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Expanded(child: ExamsScreen(embedMode: true)),
        ],
      ),
    );
  }
}
