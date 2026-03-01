import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/ui/theme/minima_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const notionTokenKey = 'notion_api_token';
  static const notionDatabaseIdKey = 'notion_inbox_database_id';
  static const notionTasksDatabaseIdKey = 'notion_tasks_database_id';
  static const notionSubtasksDatabaseIdKey = 'notion_subtasks_database_id';
  static const homeAppsAlignmentKey = 'home_apps_alignment';

  /// Values for [homeAppsAlignmentKey].
  static const alignmentLeft = 'left';
  static const alignmentRight = 'right';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _tokenController = TextEditingController();
  bool _obscureToken = true;
  bool _saved = false;
  String _alignment = SettingsScreen.alignmentLeft;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final token = await _storage.read(key: SettingsScreen.notionTokenKey);
    _tokenController.text = token ?? '';

    final alignment =
        await _storage.read(key: SettingsScreen.homeAppsAlignmentKey);
    if (alignment != null && mounted) {
      setState(() => _alignment = alignment);
    }
  }

  Future<void> _save() async {
    final value = _tokenController.text.trim();
    if (value.isEmpty) {
      await _storage.delete(key: SettingsScreen.notionTokenKey);
    } else {
      await _storage.write(key: SettingsScreen.notionTokenKey, value: value);
    }

    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _toggleAlignment() async {
    final next = _alignment == SettingsScreen.alignmentLeft
        ? SettingsScreen.alignmentRight
        : SettingsScreen.alignmentLeft;

    await _storage.write(key: SettingsScreen.homeAppsAlignmentKey, value: next);
    setState(() => _alignment = next);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: MinimaTheme.textPrimary, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Notion',
            style: TextStyle(
              color: MinimaTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            obscureText: _obscureToken,
            style: TextStyle(color: MinimaTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Integration token',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureToken ? Icons.visibility_off : Icons.visibility,
                  color: MinimaTheme.textMuted,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureToken = !_obscureToken),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: MinimaTheme.surfaceLight,
                foregroundColor: MinimaTheme.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(_saved ? 'Saved' : 'Save'),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Launcher',
            style: TextStyle(
              color: MinimaTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _toggleAlignment,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: MinimaTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Home apps alignment',
                    style: TextStyle(
                      color: MinimaTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _alignment == SettingsScreen.alignmentLeft
                        ? 'Left'
                        : 'Right',
                    style: TextStyle(
                      color: MinimaTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
