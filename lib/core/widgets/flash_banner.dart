// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/flash_message_queue.dart';

class FlashBanner extends ConsumerWidget {
  const FlashBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(flashMessageQueueProvider).current;

    if (message == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: message.color.withOpacity(0.13),
        border: Border.all(color: message.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.text,
        style: TextStyle(color: message.color),
        textAlign: TextAlign.center,
      ),
    );
  }
}
