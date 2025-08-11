import 'package:flutter/material.dart';
import 'package:minima/packages/display/display.dart';
import 'package:minima/packages/sqlite/sqlite.dart';
import 'package:minima/packages/themes/themes.dart';
import 'package:minima/providers/providers.dart';
import 'package:minima/widgets/base/home_screen.dart';

void runBase({
  Widget? home,
  void Function()? onInit,
  void Function()? onReady,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (onInit != null) {
    onInit();
  }

  await Display.initialize();
  final database = await Sqlite.initialize();

  if (onReady != null) {
    onReady();
  }

  runApp(
    Base(
      database: database,
      home: home,
    ),
  );
}

class Base extends StatelessWidget {
  final Database database;
  final Widget? home;

  const Base({
    super.key,
    required this.database,
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    final noteRepository = SqliteNoteRepository(database);
    final projectRepository = SqliteProjectRepository(database);
    final jobRepository = SqliteJobRepository(database);
    final taskRepository = SqliteTaskRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NoteProvider(
            notes: noteRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ProjectProvider(
            jobs: jobRepository,
            projects: projectRepository,
            tasks: taskRepository,
          ),
        ),
      ],
      child: MaterialApp(
        theme: blackTheme.themeData,
        home: const Scaffold(
          body: SafeArea(
            child: Display(
              child: HomeScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
