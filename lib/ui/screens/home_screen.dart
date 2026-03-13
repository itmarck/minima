import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/data/local/database.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/package_info.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/screens/package_list_screen.dart';
import 'package:minima/ui/screens/settings_screen.dart';
import 'package:minima/ui/widgets/drafts_modal.dart';
import 'package:minima/ui/widgets/favorite_apps.dart';
import 'package:minima/ui/widgets/home_top_bar.dart';
import 'package:minima/ui/widgets/input_overlay.dart';
import 'package:minima/ui/widgets/input_shell.dart';
import 'package:minima/ui/widgets/task_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  final DraftManager draftManager;
  final SyncEngine syncEngine;
  final PackageManager? packageManager;
  final TaskManager? taskManager;
  final AppDatabase database;
  final Alignment initialAlignment;

  const HomeScreen({
    super.key,
    required this.draftManager,
    required this.syncEngine,
    required this.database,
    this.packageManager,
    this.taskManager,
    this.initialAlignment = Alignment.centerLeft,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const _maxActionableResults = 5;

  static const _tripleTapWindow = Duration(milliseconds: 500);

  final _controller = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<TaskItem> _taskItems = [];
  List<PackageInfo> _homePackages = [];
  int _pendingCount = 0;
  bool _isSyncing = false;
  Alignment _appsAlignment = Alignment.centerLeft;
  int _tapCount = 0;
  DateTime _lastTapTime = DateTime(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTaskItems();
    _loadHomePackages();
    _loadPendingCount();

    widget.syncEngine.onSyncStart = () {
      if (mounted) setState(() => _isSyncing = true);
    };

    widget.syncEngine.onSyncComplete = () {
      if (mounted) {
        _loadTaskItems();
        _loadPendingCount();
        setState(() => _isSyncing = false);
      }
    };

    _appsAlignment = widget.initialAlignment;
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
    final value = await _storage.read(key: SettingsScreen.homeAppsAlignmentKey);
    if (mounted && value != null) {
      setState(() {
        _appsAlignment = value == SettingsScreen.alignmentRight
            ? Alignment.centerRight
            : Alignment.centerLeft;
      });
    }
  }

  List<Actionable> _searchActionables(String query) {
    final results = <Actionable>[];

    final packageManager = widget.packageManager;
    if (packageManager != null) {
      final packages = packageManager.search(query);
      results.addAll(
        packages.map(
          (p) => Actionable(label: p.label, id: p.packageName, type: ActionableType.package),
        ),
      );
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

  void _handleTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapTime) > _tripleTapWindow) {
      _tapCount = 0;
    }
    _tapCount++;
    _lastTapTime = now;

    if (_tapCount >= 3) {
      _tapCount = 0;
      widget.syncEngine.sync();
    }
  }

  void _openPackageList() {
    final packageManager = widget.packageManager;
    if (packageManager == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PackageListScreen(packageManager: packageManager)),
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
    showTaskBottomSheet(context, items: _taskItems, onComplete: _completeItem);
  }

  void _showInputOverlay() {
    showInputOverlay(
      context,
      controller: _controller,
      searchActionables: _searchActionables,
      onExecute: _executeActionable,
      onSubmit: _submit,
    );
  }

  void _showDraftsModal() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final allDrafts = await widget.draftManager.getAll();
    final recentDrafts = allDrafts.where((d) => d.createdAt.isAfter(cutoff)).toList();

    if (!mounted) return;

    showDraftsModal(context, drafts: recentDrafts);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      widget.syncEngine.sync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Override padding with viewPadding so SafeArea uses the stable value
    // that doesn't drop to 0 when the keyboard opens.
    final mediaQuery = MediaQuery.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: MediaQuery(
          data: mediaQuery.copyWith(padding: mediaQuery.viewPadding),
          child: SafeArea(
            child: Column(
              children: [
                HomeTopBar(
                  pendingCount: _pendingCount,
                  isSyncing: _isSyncing,
                  onSettingsTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen(database: widget.database)),
                  ).then((_) => _loadAlignment()),
                ),

                // Center: gesture area.
                // Long-press -> app list. Triple-tap -> sync.
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () {
                      if (widget.packageManager != null) _openPackageList();
                    },
                    onTap: _handleTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const Spacer(),
                          FavoriteApps(
                            homePackages: _homePackages,
                            onLaunch: (packageName) {
                              widget.packageManager?.launchPackage(packageName);
                            },
                            alignment: _appsAlignment,
                          ),
                          // Space between apps and input
                          const SizedBox(height: 120.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom: input shell with swipe-up for tasks.
                GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
                      _showTaskBottomSheet();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: InputShell(onTap: _showInputOverlay, onSwipeRight: _showDraftsModal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
