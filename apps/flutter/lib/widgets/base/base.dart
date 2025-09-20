import 'package:flutter/material.dart';
import 'package:minima/packages/display/display.dart';
import 'package:minima/packages/sqlite/sqlite.dart';
import 'package:minima/packages/themes/themes.dart';
import 'package:minima/providers/providers.dart';
import 'package:minima/specification.dart';
import 'package:minima/widgets/base/base_screen.dart';

class Base extends StatelessWidget {
  final Specification specification;
  final Database database;
  final Widget? home;

  const Base({
    super.key,
    required this.specification,
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
        home: Scaffold(
          appBar: specification.appBar(context),
          body: Display(
            child: SafeArea(
              child: BaseScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
