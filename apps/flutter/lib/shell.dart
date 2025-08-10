import 'package:flutter/material.dart';
import 'package:minima/packages/display/display.dart';
import 'package:minima/packages/sqlite/sqlite.dart';
import 'package:minima/packages/themes/themes.dart';
import 'package:minima/providers/providers.dart';
import 'package:minima/widgets/common/home_screen.dart';

abstract class Slots {
  Widget get home;
}

class Shell extends StatelessWidget {
  final Database database;
  final Slots? slots;

  const Shell({
    super.key,
    required this.database,
    this.slots,
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
