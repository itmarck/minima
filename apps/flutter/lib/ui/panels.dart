import 'package:flutter/material.dart';

class Panels extends StatefulWidget {
  final List<Widget> pages;
  final PageController? controller;

  const Panels({
    super.key,
    required this.pages,
    this.controller,
  }) : assert(pages.length == 3, 'Panels must have 3 pages');

  @override
  State<Panels> createState() => _PanelsState();
}

class _PanelsState extends State<Panels> {
  final PageController _controller = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _controller.animateToPage(
          _controller.initialPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      },
      child: PageView(
        physics: const ClampingScrollPhysics(),
        controller: _controller,
        children: [
          widget.pages.first,
          widget.pages.elementAt(1),
          widget.pages.last,
        ],
      ),
    );
  }
}
