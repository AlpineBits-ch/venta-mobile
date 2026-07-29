import 'dart:async';

import 'package:flutter/material.dart';

/// Live "mm:ss" (or "h:mm:ss" past an hour) duration since [since], ticking
/// locally via its own Timer rather than through a cubit — this is purely a
/// display concern with nothing else caring about the current second, so
/// there's no reason to push a rebuild through the bloc layer for it.
class ElapsedTimeLabel extends StatefulWidget {
  const ElapsedTimeLabel({super.key, required this.since, this.style});

  final DateTime since;
  final TextStyle? style;

  @override
  State<ElapsedTimeLabel> createState() => _ElapsedTimeLabelState();
}

class _ElapsedTimeLabelState extends State<ElapsedTimeLabel> {
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
    final elapsed = DateTime.now().difference(widget.since);
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final text = elapsed.inHours > 0 ? '${elapsed.inHours}:$minutes:$seconds' : '$minutes:$seconds';
    return Text(text, style: widget.style ?? const TextStyle(color: Colors.white54, fontSize: 13));
  }
}
