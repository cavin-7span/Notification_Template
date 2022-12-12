import 'package:flutter/material.dart';

class DynamicDialog extends StatelessWidget {
  final String? title;
  final String? body;
  const DynamicDialog({super.key, this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "N/A"),
      actions: [
        OutlinedButton.icon(
          label: const Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        )
      ],
      content: Text(body ?? "N/A"),
    );
  }
}
