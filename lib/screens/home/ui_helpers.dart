import 'package:flutter/material.dart';

Future<void> showAutoDialog(
  BuildContext context, {
  required String message,
  bool isError = false,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 2));
  if (context.mounted) Navigator.pop(context);
}
