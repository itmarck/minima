import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/data/local/database.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/screens/package_list_screen.dart';
import 'package:minima/ui/screens/settings_screen.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/actionable_results.dart';
import 'package:minima/ui/widgets/favorite_apps.dart';
import 'package:minima/ui/widgets/task_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final DraftManager draftManager;
  final SyncEngine syncEngine;
  final PackageManager? packageManager;
  final TaskManager? taskManager;
  final AppDatabase database;

  const HomeScreen({
    super.key,
    required this.draftManager,
    required this.syncEngine,
    required this.database,
    this.packageManager,
    this.taskManager,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _maxActionableResults = 3;

  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<Actionable> _actionables = [];
  List<TaskItem> _taskItems = [];
  List<PackageInfo> _homePackages = [];
  int _pendingCount = 0;
  Alignment _appsAlignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onInputChanged);
    _loadTaskItems();
    _loadHomePackages();
    _loadPendingCount();
    _loadAlignment();

    widget.syncEngine.onSyncComplete = () {
      if (mounted) {
        _loadTaskItems();
        _loadPendingCount();
      }
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

  void _loadHomePackages() {
    final packageManager = widget.packageManager;
    if (packageManager == null) return;

    setState(() => _homePackages = packageManager.homePackages);
  }

  Future<void> _loadPendingCount() async {
    final taskManager = widget.taskManager;
    if (taskManager == null) return;

    final count = await taskManager.getPendingCount();
    if (mounted) {
      setState(() => _pendingCount = count);
    }
  }

  Future<void> _loadAlignment() async {
    final value =
        await _storage.read(key: SettingsScreen.homeAppsAlignmentKey);
    if (mounted && value != null) {
      setState(() {
        _appsAlignment = value == SettingsScreen.alignmentRight
            ? Alignment.centerRight
            : Alignment.centerLeft;
      });
    }
  }

  void _onInputChanged() {
    setState(() {
      _actionables = _searchActionables(_controller.text);
    });
  }

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
    ).then((_) => _loadHomePackages());
  }

  Future<void> _completeItem(TaskItem item) async {
    setState(() {
      _taskItems = _taskItems.where((i) => i.id != item.id).toList();
      if (_pendingCount > 0) _pendingCount--;
    });

    await widget.taskManager?.markComplete(item);
    widget.syncEngine.sync();
  }

  void _showTaskBottomSheet() {
    showTaskBottomSheet(
      context,
      items: _taskItems,
      onComplete: _completeItem,
    );
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
            // Top bar: pending count (left) + settings icon (right).
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_pendingCount > 0)
                    Text(
                      '$_pendingCount pending',
                      style: TextStyle(
                        color: MinimaTheme.textMuted,
                        fontSize: 13,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: MinimaTheme.textMuted,
                      size: 22,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(database: widget.database),
                      ),
                    ).then((_) => _loadAlignment()),
                  ),
                ],
              ),
            ),

            // Center: long-press on background to open app list.
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress:
                    widget.packageManager != null ? _openPackageList : null,
                child: const SizedBox.expand(),
              ),
            ),

            // Bottom: input + swipe up for tasks.
            GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -300) {
                  _showTaskBottomSheet();
                }
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FavoriteApps(
                      homePackages: _homePackages,
                      onLaunch: (packageName) =>
                          widget.packageManager?.launchPackage(packageName),
                      alignment: _appsAlignment,
                    ),
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
