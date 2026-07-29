import 'dart:async';

import 'package:flutter/material.dart';

/// Live "mm:ss" countdown to [deadline] — counterpart to [ElapsedTimeLabel]
/// for the multi-device calling "alone" grace period. Ticks locally via its
/// own Timer for the same reason: a pure display concern, no need to push a
/// rebuild through the bloc layer for it.
class CountdownLabel extends StatefulWidget {
  const CountdownLabel({super.key, required this.deadline, this.style});

  final DateTime deadline;
  final TextStyle? style;

  @override
  State<CountdownLabel> createState() => _CountdownLabelState();
}

class _CountdownLabelState extends State<CountdownLabel> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.deadline.difference(DateTime.now());
    final clamped = remaining.isNegative ? Duration.zero : remaining;
    final seconds = (clamped.inSeconds % 60).toString().padLeft(2, '0');
    final minutes = (clamped.inMinutes % 60).toString().padLeft(2, '0');
    return Text('$minutes:$seconds', style: widget.style ?? const TextStyle(color: Colors.white54, fontSize: 13));
  }
}
