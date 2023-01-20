import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HazardPromptDialog extends HookConsumerWidget {
  final String type;
  const HazardPromptDialog({Key? key, this.type = 'post'}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return AlertDialog(
      title: const Text('Confirm Delete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.warning_outlined,
              color: Colors.red[400],
              size: 40,
            ),
          ),
          Text(
            'Are you sure you want to delete this $type?',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
