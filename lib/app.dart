import 'package:flutter/material.dart';
import 'package:minima/data/local/database.dart';
import 'package:minima/data/local/draft_dao.dart';
import 'package:minima/data/local/subtask_dao.dart';
import 'package:minima/data/local/task_dao.dart';
import 'package:minima/data/platform/platform_package_repository.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/package_manager.dart';
import 'package:minima/domain/task_manager.dart';
import 'package:minima/ui/screens/home_screen.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class MinimaApp extends StatefulWidget {
  const MinimaApp({super.key});

  @override
  State<MinimaApp> createState() => _MinimaAppState();
}

class _MinimaAppState extends State<MinimaApp> {
  AppDatabase? _db;
  DraftManager? _draftManager;
  SyncEngine? _syncEngine;
  PackageManager? _packageManager;
  TaskManager? _taskManager;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = await AppDatabase.open();
    final draftDao = DraftDao(db);
    final taskDao = TaskDao(db);
    final subtaskDao = SubtaskDao(db);

    final syncEngine = SyncEngine(
      draftRepository: draftDao,
      taskRepository: taskDao,
      subtaskRepository: subtaskDao,
    );
    syncEngine.start();

    final packageRepository = PlatformPackageRepository();
    final packageManager = PackageManager(repository: packageRepository);
    await packageManager.loadPackages();

    final taskManager = TaskManager(
      taskRepository: taskDao,
      subtaskRepository: subtaskDao,
    );

    setState(() {
      _db = db;
      _draftManager = DraftManager(repository: draftDao);
      _syncEngine = syncEngine;
      _packageManager = packageManager;
      _taskManager = taskManager;
    });
  }

  @override
  void dispose() {
    _syncEngine?.stop();
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minima',
      debugShowCheckedModeBanner: false,
      theme: MinimaTheme.data,
      home: _draftManager != null
          ? HomeScreen(
              draftManager: _draftManager!,
              syncEngine: _syncEngine!,
              packageManager: _packageManager,
              taskManager: _taskManager,
            )
          : Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: MinimaTheme.accent),
              ),
            ),
    );
  }
}
