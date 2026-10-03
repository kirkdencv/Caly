import 'package:flutter/material.dart';

/// Keeps phone-first screens readable when the web app is opened in a wide
/// desktop window without changing their behavior on small devices.
class CalyPageBody extends StatelessWidget {
  const CalyPageBody({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
