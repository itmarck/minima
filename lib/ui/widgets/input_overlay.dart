import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:minima/domain/actionable.dart';
import 'package:minima/ui/theme/minima_theme.dart';
import 'package:minima/ui/widgets/actionable_results.dart';
import 'package:minima/ui/widgets/input_container.dart';

/// Shows the input overlay as a route with a fade transition.
///
/// Returns a [Future] that completes when the overlay is dismissed.
Future<void> showInputOverlay(
  BuildContext context, {
  required TextEditingController controller,
  required List<Actionable> Function(String query) searchActionables,
  required void Function(Actionable actionable) onExecute,
  required Future<void> Function() onSubmit,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _InputOverlay(
          controller: controller,
          searchActionables: searchActionables,
          onExecute: onExecute,
          onSubmit: onSubmit,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _InputOverlay extends StatefulWidget {
  final TextEditingController controller;
  final List<Actionable> Function(String query) searchActionables;
  final void Function(Actionable actionable) onExecute;
  final Future<void> Function() onSubmit;

  const _InputOverlay({
    required this.controller,
    required this.searchActionables,
    required this.onExecute,
    required this.onSubmit,
  });

  @override
  State<_InputOverlay> createState() => _InputOverlayState();
}

class _InputOverlayState extends State<_InputOverlay> with WidgetsBindingObserver {
  final _focusNode = FocusNode();
  List<Actionable> _actionables = [];
  bool _keyboardVisible = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onSearchChanged);
    _actionables = widget.searchActionables(widget.controller.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    route?.animation?.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onSearchChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottom = WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    final isNowVisible = bottom > 0;

    if (_keyboardVisible && !isNowVisible) {
      _close();
    }
    _keyboardVisible = isNowVisible;
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    _focusNode.unfocus();
    Navigator.of(context).pop();
  }

  void _handleExecute(Actionable actionable) {
    widget.onExecute(actionable);
    _close();
  }

  Future<void> _handleSubmit() async {
    await widget.onSubmit();
    _close();
  }

  void _onSearchChanged() {
    setState(() {
      _actionables = widget.searchActionables(widget.controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _close,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox.expand(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + keyboardHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_actionables.isNotEmpty)
                        ActionableResults(results: _actionables, onTap: _handleExecute),
                      InputContainer(
                        trailing: IconButton(
                          icon: Icon(Icons.arrow_upward_rounded, color: colors.textMuted),
                          onPressed: _handleSubmit,
                          padding: EdgeInsets.all(16.0),
                          constraints: const BoxConstraints(),
                        ),
                        child: TextField(
                          controller: widget.controller,
                          focusNode: _focusNode,
                          maxLines: null,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration.collapsed(
                            hintText: InputContainer.hintText,
                            hintStyle: TextStyle(color: colors.textMuted, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
