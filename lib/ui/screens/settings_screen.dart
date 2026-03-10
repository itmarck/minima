import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:minima/data/local/database.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/confirm_dialog.dart';
import 'package:minima/ui/widgets/section_header.dart';
import 'package:minima/ui/widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  final AppDatabase database;

  const SettingsScreen({super.key, required this.database});

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

    final alignment = await _storage.read(key: SettingsScreen.homeAppsAlignmentKey);
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

  Future<void> _clearCache() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear cache',
      message: 'Removes cached Notion database IDs. They will be re-discovered on the next sync.',
    );
    if (!confirmed) return;

    await _storage.delete(key: SettingsScreen.notionDatabaseIdKey);
    await _storage.delete(key: SettingsScreen.notionTasksDatabaseIdKey);
    await _storage.delete(key: SettingsScreen.notionSubtasksDatabaseIdKey);
  }

  Future<void> _clearData() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear local data',
      message: 'Permanently deletes all local drafts, tasks, and subtasks. This cannot be undone.',
    );
    if (!confirmed) return;

    await widget.database.db.delete('drafts');
    await widget.database.db.delete('tasks');
    await widget.database.db.delete('subtasks');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SectionHeader(title: 'Notion'),
          const SizedBox(height: 16),
          TextField(
            controller: _tokenController,
            obscureText: _obscureToken,
            style: textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Integration token',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureToken ? Icons.visibility_off : Icons.visibility,
                  color: colors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureToken = !_obscureToken),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              key: ValueKey(_saved),
              onPressed: _save,
              child: Text(_saved ? 'Saved' : 'Save'),
            ),
          ),
          const SizedBox(height: 40),
          const SectionHeader(title: 'Launcher'),
          const SizedBox(height: 16),
          SettingsTile(
            label: 'Home apps alignment',
            value: _alignment == SettingsScreen.alignmentLeft ? 'Left' : 'Right',
            onTap: _toggleAlignment,
          ),
          const SizedBox(height: 40),
          const SectionHeader(title: 'Storage'),
          const SizedBox(height: 16),
          SettingsTile(label: 'Clear cache', value: 'Notion DB IDs', onTap: _clearCache),
          const SizedBox(height: 8),
          SettingsTile(
            label: 'Clear local data',
            value: 'Drafts, tasks, subtasks',
            onTap: _clearData,
          ),
        ],
      ),
    );
  }
}
