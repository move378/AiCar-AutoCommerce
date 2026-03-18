import 'dart:async';

import 'package:flutter/material.dart';

class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 30),
    this.onComplete,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;
  bool _isComplete = false;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _currentIndex++;
          _displayedText = widget.text.substring(0, _currentIndex);
        });
      } else {
        timer.cancel();
        _cursorTimer?.cancel();
        setState(() {
          _isComplete = true;
          _showCursor = false;
        });
        widget.onComplete?.call();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isComplete && mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: _displayedText),
          if (!_isComplete)
            TextSpan(
              text: _showCursor ? '|' : ' ',
              style: widget.style?.copyWith(
                fontWeight: FontWeight.w300,
              ),
            ),
        ],
      ),
    );
  }
}
