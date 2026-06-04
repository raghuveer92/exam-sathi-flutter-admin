import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_colors.dart' show AdminColors;
import '../../../data/models/exam_category_model.dart';
import '../../../data/repositories/exam_category_repository.dart';

class ExamCategoriesScreen extends StatefulWidget {
  const ExamCategoriesScreen({super.key});

  @override
  State<ExamCategoriesScreen> createState() => _ExamCategoriesScreenState();
}

class _ExamCategoriesScreenState extends State<ExamCategoriesScreen> {
  final _repo = GetIt.I<ExamCategoryRepository>();
  List<ExamCategoryModel> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AdminColors.error),
      );
    }
  }

  Future<void> _showDialog({ExamCategoryModel? category}) async {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    final descCtrl = TextEditingController(text: category?.description ?? '');
    final iconCtrl = TextEditingController(text: category?.icon ?? 'category');
    final orderCtrl =
        TextEditingController(text: '${category?.displayOrder ?? 0}');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: iconCtrl,
                decoration: const InputDecoration(
                    labelText: 'Icon key (e.g. school, engineering)'),
              ),
              TextField(
                controller: orderCtrl,
                decoration: const InputDecoration(labelText: 'Display order'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;

    final data = {
      'name': nameCtrl.text.trim(),
      'description': descCtrl.text.trim(),
      'icon': iconCtrl.text.trim(),
      'displayOrder': int.tryParse(orderCtrl.text.trim()) ?? 0,
      'isActive': true,
    };

    try {
      if (category == null) {
        await _repo.create(data);
      } else {
        await _repo.update(category.id, data);
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AdminColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Categories'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showDialog()),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _categories.removeAt(oldIndex);
                  _categories.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) {
                final c = _categories[i];
                return Card(
                  key: ValueKey(c.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.description ?? '${c.examCount} exams'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showDialog(category: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AdminColors.error),
                          onPressed: () async {
                            await _repo.delete(c.id);
                            await _load();
                          },
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
