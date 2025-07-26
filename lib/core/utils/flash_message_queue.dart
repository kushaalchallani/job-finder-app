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
    debugPrint('🟡 [QUEUE] Enqueuing message: ${message.text}');
    debugPrint(
      '🟡 [QUEUE] Current queue size: ${_queue.length}, Current message: ${_current?.text ?? "none"}',
    );

    if (_current != null) {
      debugPrint(
        '🟡 [QUEUE] Current message exists, inserting at front of queue',
      );
      _queue.insert(0, message);
      _cancelAndReplaceNow();
    } else {
      debugPrint('🟡 [QUEUE] No current message, adding to queue');
      _queue.add(message);
      _showNext();
    }
  }

  void _cancelAndReplaceNow() {
    debugPrint('🟡 [QUEUE] Cancelling current message and replacing');
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _current = null;
    notifyListeners();
    Future.microtask(_showNext);
  }

  void _showNext() {
    debugPrint(
      '🟡 [QUEUE] _showNext called - Queue size: ${_queue.length}, Current: ${_current?.text ?? "none"}',
    );

    if (_current == null && _queue.isNotEmpty) {
      _current = _queue.removeAt(0);
      debugPrint('🟡 [QUEUE] Showing message: ${_current!.text}');
      notifyListeners();

      _dismissTimer = Timer(const Duration(seconds: 3), () {
        debugPrint(
          '🟡 [QUEUE] Timer expired, dismissing message: ${_current?.text}',
        );
        _current = null;
        notifyListeners();
        _showNext();
      });
    } else {
      debugPrint(
        '🟡 [QUEUE] No message to show - Current: ${_current?.text ?? "none"}, Queue empty: ${_queue.isEmpty}',
      );
    }
  }

  void clearCurrent() {
    debugPrint(
      '🟡 [QUEUE] Clearing current message: ${_current?.text ?? "none"}',
    );
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
