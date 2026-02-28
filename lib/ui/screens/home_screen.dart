import 'package:flutter/material.dart';
import 'package:minima/data/sync/sync_engine.dart';
import 'package:minima/domain/draft.dart';
import 'package:minima/domain/draft_manager.dart';
import 'package:minima/domain/sync_status.dart';
import 'package:minima/ui/screens/settings_screen.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/digital_clock.dart';

class HomeScreen extends StatefulWidget {
  final DraftManager draftManager;
  final SyncEngine syncEngine;

  const HomeScreen({
    super.key,
    required this.draftManager,
    required this.syncEngine,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await widget.draftManager.create(text);
    _controller.clear();

    // Trigger background sync for pending drafts.
    widget.syncEngine.syncPendingDrafts();
  }

  void _showDraftsModal() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    final allDrafts = await widget.draftManager.getAll();
    final recentDrafts =
        allDrafts.where((d) => d.createdAt.isAfter(cutoff)).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: MinimaTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _DraftsModal(drafts: recentDrafts),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with settings icon.
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: MinimaTheme.textMuted,
                    size: 22,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                ),
              ),
            ),

            // Clock centered vertically.
            const Expanded(
              child: Center(child: DigitalClock()),
            ),

            // Input and drafts link at the bottom.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    style: const TextStyle(
                      color: MinimaTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'New task...',
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          color: MinimaTheme.textMuted,
                        ),
                        onPressed: _submit,
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showDraftsModal,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Text(
                        'Show drafts',
                        style: TextStyle(
                          color: MinimaTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftsModal extends StatelessWidget {
  final List<Draft> drafts;

  const _DraftsModal({required this.drafts});

  @override
  Widget build(BuildContext context) {
    if (drafts.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'No recent drafts',
            style: TextStyle(color: MinimaTheme.textMuted),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final isSynced = draft.syncStatus == SyncStatus.synced;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Opacity(
            opacity: isSynced ? 0.4 : 1.0,
            child: Row(
              children: [
                Icon(
                  isSynced ? Icons.check_circle_outline : Icons.schedule,
                  color: MinimaTheme.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    draft.title,
                    style: const TextStyle(
                      color: MinimaTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
