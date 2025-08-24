import 'package:flutter/material.dart';
import 'package:minima/providers/providers.dart';
import 'package:minima/widgets/launcher/apps.dart';

// Theme constants
const kScaffoldBg = Color(0xFF0A0A0A);
const kCardBg = Color(0xFF1E1E1E);
const kInputFill = Color(0xFF1A1A1A);
const kSurface = Color(0xFF121212);
const kDivider = Colors.white10;
const kTextPrimary = Colors.white;
const kTextSecondary = Colors.white70;
const kTextHint = Colors.white54;
const kRadius12 = BorderRadius.all(Radius.circular(12));
const kSheetRadius = BorderRadius.vertical(top: Radius.circular(16));

class LauncherHome extends StatefulWidget {
  const LauncherHome({super.key});

  @override
  State<LauncherHome> createState() => _LauncherHomeState();
}

class _LauncherHomeState extends State<LauncherHome> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final DraggableScrollableController _sheetCtrl = DraggableScrollableController();

  static const double _minSheet = 0.5;
  static const double _maxSheet = 0.9;

  double _sheetExtent = _minSheet;
  double _dragStartExtent = _minSheet;
  bool _isSheetOpen = false;
  bool _showOptions = false;

  final List<String> _inputOptions = const ['Note', 'Task', 'Reminder'];
  int _selectedOption = 0;

  @override
  void initState() {
    super.initState();

    NoteProvider.of(context).load();
    _inputFocus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _inputFocus.removeListener(_onFocusChange);
    _controller.dispose();
    _inputFocus.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showOptions = _inputFocus.hasFocus;
    });
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await NoteProvider.of(context).addNote(text);
    _controller.clear();
  }

  void _openSheet() {
    if (_isSheetOpen) {
      _sheetCtrl.jumpTo(_sheetExtent.clamp(_minSheet, _maxSheet));
      return;
    }
    _isSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(borderRadius: kSheetRadius),
      builder: (_) => _NotesSheet(
        controller: _sheetCtrl,
        initialSize: _sheetExtent.clamp(_minSheet, _maxSheet),
        minSize: _minSheet,
        maxSize: _maxSheet,
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isSheetOpen = false;
          _sheetExtent = _minSheet;
        });
      }
    });
  }

  final List<String> apps = const ['Phone', 'Messages', 'Browser', 'Camera'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24.0),
              for (final app in apps)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(app, overflow: TextOverflow.ellipsis),
                ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _inputFocus.unfocus();
                  },
                  onLongPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Apps()),
                    );
                  },
                ),
              ),
              _InputArea(
                controller: _controller,
                focusNode: _inputFocus,
                showOptions: _showOptions,
                options: _inputOptions,
                selectedOption: _selectedOption,
                onOptionSelect: (i) => setState(() => _selectedOption = i),
                onSubmit: _addNote,
                onDragStart: () => _dragStartExtent = _sheetExtent,
                onDragUpdate: (details) {
                  final dy = -details.delta.dy / MediaQuery.of(context).size.height;
                  setState(() {
                    _sheetExtent = (_dragStartExtent + dy).clamp(_minSheet, _maxSheet);
                  });
                  _openSheet();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showOptions;
  final List<String> options;
  final int selectedOption;
  final ValueChanged<int> onOptionSelect;
  final VoidCallback onSubmit;
  final VoidCallback onDragStart;
  final ValueChanged<DragUpdateDetails> onDragUpdate;

  const _InputArea({
    required this.controller,
    required this.focusNode,
    required this.showOptions,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelect,
    required this.onSubmit,
    required this.onDragStart,
    required this.onDragUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) => onDragStart(),
      onVerticalDragUpdate: onDragUpdate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            focusNode: focusNode,
            controller: controller,
            style: const TextStyle(color: kTextPrimary),
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              hintText: 'What is on your mind?',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              filled: true,
              fillColor: kInputFill,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: kRadius12,
              ),
              hintStyle: TextStyle(color: kTextHint),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: showOptions
                ? _OptionTabs(
                    options: options,
                    selected: selectedOption,
                    onSelect: onOptionSelect,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _OptionTabs extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _OptionTabs({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kDivider),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: _TabChip(
                label: options[i],
                selected: i == selected,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? kTextPrimary : kTextSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _NotesSheet extends StatelessWidget {
  final DraggableScrollableController controller;
  final double initialSize;
  final double minSize;
  final double maxSize;

  const _NotesSheet({
    required this.controller,
    required this.initialSize,
    required this.minSize,
    required this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: kSheetRadius,
          ),
          child: Consumer<NoteProvider>(
            builder: (context, noteProvider, _) {
              final notes = noteProvider.items;
              if (notes.isEmpty) {
                return const Center(
                  child: Text(
                    'No notes yet',
                    style: TextStyle(color: kTextSecondary),
                  ),
                );
              }
              return ListView.separated(
                controller: scrollController,
                itemCount: notes.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: kDivider),
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.note, color: kTextSecondary),
                  title: Text(
                    notes[i].content,
                    style: const TextStyle(color: kTextPrimary),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
