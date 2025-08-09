import 'package:flutter/material.dart';
import 'package:minima/poc/inspector_widget.dart';
import 'package:minima/poc/note_widget.dart';
import 'package:minima/poc/project_widget.dart';
import 'package:provider/provider.dart';

import 'note_provider.dart';
import 'note_sqlite_repository.dart';
import 'project_provider.dart';
import 'project_sqlite_repository.dart';

Widget buildApp() {
  final noteRepo = SqliteNoteRepository();
  final projectRepo = SqliteProjectRepository();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NoteModel(noteRepo)),
      ChangeNotifierProvider(create: (_) => ProjectModel(projectRepo)),
    ],
    child: MaterialApp(
      title: 'Minima PoC',
      theme: ThemeData(colorSchemeSeed: Colors.blueAccent, useMaterial3: true),
      home: const Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(padding: EdgeInsets.all(16.0), child: InspectorWidget()),
              ),
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
