import 'package:flutter/material.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/screens/package_list_screen.dart';
import 'package:minima/ui/screens/settings_screen.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/actionable_results.dart';

class HomeScreen extends StatefulWidget {
  final DraftManager draftManager;
  final SyncEngine syncEngine;
  final PackageManager? packageManager;
  final TaskManager? taskManager;

  const HomeScreen({
    super.key,
    required this.draftManager,
    required this.syncEngine,
    this.packageManager,
    this.taskManager,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _maxActionableResults = 3;

  final _controller = TextEditingController();
  List<Actionable> _actionables = [];
  List<TaskItem> _taskItems = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onInputChanged);
    _loadTaskItems();

    widget.syncEngine.onSyncComplete = () {
      if (mounted) _loadTaskItems();
    };
  }

  Future<void> _loadTaskItems() async {
    final taskManager = widget.taskManager;
    if (taskManager == null) return;

    final items = await taskManager.getActiveItems();
    if (mounted) {
      setState(() => _taskItems = items);
    }
  }

  void _onInputChanged() {
    setState(() {
      _actionables = _searchActionables(_controller.text);
    });
  }

  /// Builds actionable results from all available sources.
  /// Currently: packages. Extensible to settings, commands, etc.
  List<Actionable> _searchActionables(String query) {
    final results = <Actionable>[];

    final packageManager = widget.packageManager;
    if (packageManager != null) {
      final packages = packageManager.search(query);
      results.addAll(packages.map((p) => Actionable(
            label: p.label,
            id: p.packageName,
            type: ActionableType.package,
          )));
    }

    // Future sources: settings, commands, etc.

    return results.take(_maxActionableResults).toList();
  }

  void _executeActionable(Actionable actionable) {
    switch (actionable.type) {
      case ActionableType.package:
        widget.packageManager?.launchPackage(actionable.id);
    }
    _controller.clear();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await widget.draftManager.create(text);
    _controller.clear();

    // Trigger background sync for pending drafts.
    widget.syncEngine.syncPendingDrafts();
  }

  void _openPackageList() {
    final packageManager = widget.packageManager;
    if (packageManager == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PackageListScreen(packageManager: packageManager),
      ),
    );
  }

  Future<void> _completeItem(TaskItem item) async {
    // Optimistic UI: remove from list immediately.
    setState(() {
      _taskItems = _taskItems.where((i) => i.id != item.id).toList();
    });

    await widget.taskManager?.markComplete(item);
    widget.syncEngine.sync();
  }

  void _showDraftsModal() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final allDrafts = await widget.draftManager.getAll();
    final recentDrafts =
        allDrafts.where((d) => d.createdAt.isAfter(cutoff)).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: MinimaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _DraftsModal(drafts: recentDrafts),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with settings icon.
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: MinimaTheme.textMuted,
                    size: 22,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                ),
              ),
            ),

            // Task list + long-press on background opens package list.
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress:
                    widget.packageManager != null ? _openPackageList : null,
                child: Center(
                  child: _taskItems.isNotEmpty
                      ? _TaskList(
                          items: _taskItems,
                          onComplete: _completeItem,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // Input, actionable results, and drafts link at the bottom.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ActionableResults(
                    results: _actionables,
                    onTap: _executeActionable,
                  ),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      color: MinimaTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What is on your mind?',
                      constraints: const BoxConstraints(maxHeight: 120),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          color: MinimaTheme.textMuted,
                        ),
                        onPressed: _submit,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showDraftsModal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Text(
                        'Show drafts',
                        style: TextStyle(
                          color: MinimaTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftsModal extends StatelessWidget {
  final List<Draft> drafts;

  const _DraftsModal({required this.drafts});

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No recent drafts',
            style: TextStyle(color: MinimaTheme.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final isSynced = draft.syncStatus == SyncStatus.synced;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Opacity(
            opacity: isSynced ? 0.4 : 1.0,
            child: Row(
              children: [
                Icon(
                  isSynced ? Icons.check_circle_outline : Icons.schedule,
                  color: MinimaTheme.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    draft.title,
                    style: TextStyle(
                      color: MinimaTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskItem> items;
  final ValueChanged<TaskItem> onComplete;

  const _TaskList({required this.items, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => onComplete(item),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: item.isSubtask
                              ? MinimaTheme.textMuted
                              : MinimaTheme.textSecondary,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: item.isSubtask
                              ? MinimaTheme.textSecondary
                              : MinimaTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: MinimaTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
