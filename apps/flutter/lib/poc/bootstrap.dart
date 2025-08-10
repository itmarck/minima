import 'package:flutter/material.dart';
import 'package:minima/poc/database.dart';
import 'package:minima/poc/note_widget.dart';
import 'package:minima/poc/project_widget.dart';
import 'package:provider/provider.dart';

import 'note_provider.dart';
import 'note_sqlite_repository.dart';
import 'project_provider.dart';
import 'project_sqlite_repository.dart';

Future<Widget> buildApp() async {
  final database = await AppDatabase.initialize();
  final noteRepository = SqliteNoteRepository(database);
  final projectRepository = SqliteProjectRepository(database);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NoteModel(noteRepository)),
      ChangeNotifierProvider(create: (_) => ProjectModel(projectRepository)),
    ],
    child: MaterialApp(
      title: 'Minima PoC',
      theme: ThemeData(colorSchemeSeed: Colors.blueAccent, useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(padding: EdgeInsets.all(16.0), child: NoteWidget()),
              ),
              Expanded(
                flex: 1,
                child: Padding(padding: EdgeInsets.all(16.0), child: ProjectWidget()),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
