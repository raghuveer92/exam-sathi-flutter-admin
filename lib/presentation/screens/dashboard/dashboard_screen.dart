import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/analytics_model.dart';
import '../../blocs/admin/admin_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AdminBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<AdminBloc>()..add(AdminDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is! AdminDashboardLoaded) {
              return const SizedBox.shrink();
            }
            final a = state.analytics;
            return RefreshIndicator(
              onRefresh: () async =>
                  _bloc.add(AdminDashboardRequested()),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Platform statistics at a glance',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _StatCardsGrid(analytics: a),
                    const SizedBox(height: 24),
                    if (a.topStudents.isNotEmpty) ...[
                      Text('Top Students',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _TopStudentsCard(students: a.topStudents),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCardsGrid extends StatelessWidget {
  final AnalyticsModel analytics;
  const _StatCardsGrid({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatData(
          icon: Icons.people_alt_rounded,
          label: 'Total Students',
          value: '${analytics.totalStudents}',
          color: AdminColors.statStudents),
      _StatData(
          icon: Icons.bolt_rounded,
          label: 'Active Today',
          value: '${analytics.todayActiveUsers}',
          color: AdminColors.statActive),
      _StatData(
          icon: Icons.menu_book_rounded,
          label: 'Total Exams',
          value: '${analytics.totalExams}',
          color: AdminColors.statExams),
      _StatData(
          icon: Icons.trending_up_rounded,
          label: 'Avg Completion',
          value: '${analytics.averageCompletionPercent.toStringAsFixed(1)}%',
          color: AdminColors.statCompletion),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
        children: cards.map((d) => _StatCard(data: d)).toList(),
      );
    });
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatData(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AdminColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(data.value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: data.color)),
          Text(data.label,
              style: const TextStyle(
                  fontSize: 11, color: AdminColors.textSecondary)),
        ],
      ),
    );
  }
}

class _TopStudentsCard extends StatelessWidget {
  final List<TopStudentModel> students;
  const _TopStudentsCard({required this.students});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AdminColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AdminColors.divider),
        itemBuilder: (context, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AdminColors.primary.withOpacity(0.12),
              child: Text(
                s.fullName[0].toUpperCase(),
                style: const TextStyle(
                    color: AdminColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(s.fullName,
                style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(s.email),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${s.completionPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AdminColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
                Text('🔥 ${s.streakDays}d',
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }
}
