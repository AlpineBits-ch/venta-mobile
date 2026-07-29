import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/wiki_category_dto.dart';
import '../../data/wiki_repository.dart';

/// Flat, position-ordered category list with drag-to-reorder — mobile v1's
/// simplification of Alpine's nestable/drag-droppable category tree.
class WikiCategoryManagerScreen extends StatefulWidget {
  const WikiCategoryManagerScreen({super.key, required this.guildId});

  final String guildId;

  @override
  State<WikiCategoryManagerScreen> createState() => _WikiCategoryManagerScreenState();
}

class _WikiCategoryManagerScreenState extends State<WikiCategoryManagerScreen> {
  List<WikiCategoryDto>? _categories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final wiki = await getIt<WikiRepository>().getWiki(widget.guildId);
      final categories = [...wiki.categories]..sort((a, b) => a.position.compareTo(b.position));
      if (mounted) setState(() => _categories = categories);
    } catch (_) {
      if (mounted) setState(() => _categories = const []);
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final categories = _categories;
    if (categories == null) return;
    setState(() {
      final category = categories.removeAt(oldIndex);
      categories.insert(newIndex, category);
    });
    try {
      for (var i = 0; i < categories.length; i++) {
        if (categories[i].position != i) {
          await getIt<WikiRepository>().updateCategory(widget.guildId, categories[i].id, position: i);
        }
      }
    } catch (_) {
      await _load();
    }
  }

  Future<void> _create() async {
    final name = await _promptForName(title: 'New category');
    if (name == null || name.trim().isEmpty) return;
    try {
      await getIt<WikiRepository>()
          .createCategory(widget.guildId, name: name.trim(), position: (_categories?.length ?? 0));
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not create that category.')));
      }
    }
  }

  Future<void> _rename(WikiCategoryDto category) async {
    final name = await _promptForName(title: 'Rename category', initial: category.name);
    if (name == null || name.trim().isEmpty || name.trim() == category.name) return;
    try {
      await getIt<WikiRepository>().updateCategory(widget.guildId, category.id, name: name.trim());
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not rename that category.')));
      }
    }
  }

  Future<void> _delete(WikiCategoryDto category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Pages in "${category.name}" become uncategorized, not deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await getIt<WikiRepository>().deleteCategory(widget.guildId, category.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not delete that category.')));
      }
    }
  }

  Future<String?> _promptForName({required String title, String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Category name')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categories == null
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? const Center(child: Text('No categories yet.'))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                  itemCount: categories.length,
                  onReorderItem: _reorder,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      key: ValueKey(category.id),
                      leading: const Icon(Icons.drag_handle),
                      title: Text(category.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _rename(category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        tooltip: 'New category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
