import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashMessage {
  final String text;
  final Color color;

  FlashMessage({required this.text, required this.color});
}

class FlashMessageQueue extends ChangeNotifier {
  final List<FlashMessage> _queue = [];
  FlashMessage? _current;
  Timer? _dismissTimer;

  FlashMessage? get current => _current;

  void enqueue(FlashMessage message) {
    if (_current != null) {
      _queue.insert(0, message);
      _cancelAndReplaceNow();
    } else {
      _queue.add(message);
      _showNext();
    }
  }

  void _cancelAndReplaceNow() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _current = null;
    notifyListeners();
    Future.microtask(_showNext);
  }

  void _showNext() {
    if (_current == null && _queue.isNotEmpty) {
      _current = _queue.removeAt(0);
      notifyListeners();

      _dismissTimer = Timer(const Duration(seconds: 3), () {
        _current = null;
        notifyListeners();
        _showNext();
      });
    }
  }

  void clearCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _current = null;
    notifyListeners();
    _showNext();
  }
}

final flashMessageQueueProvider = ChangeNotifierProvider<FlashMessageQueue>((
  ref,
) {
  return FlashMessageQueue();
});
