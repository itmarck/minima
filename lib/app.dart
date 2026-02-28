import 'package:flutter/material.dart';
import 'package:minima/data/local/database.dart';
import 'package:minima/data/local/draft_dao.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/ui/screens/home_screen.dart';

class MinimaApp extends StatefulWidget {
  const MinimaApp({super.key});

  @override
  State<MinimaApp> createState() => _MinimaAppState();
}

class _MinimaAppState extends State<MinimaApp> {
  AppDatabase? _db;
  DraftManager? _draftManager;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final db = await AppDatabase.open();
    setState(() {
      _db = db;
      _draftManager = DraftManager(repository: DraftDao(db));
    });
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: _draftManager != null
          ? HomeScreen(draftManager: _draftManager!)
          : const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
    );
  }
}
