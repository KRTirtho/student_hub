import 'package:catcher/catcher.dart' hide Report;
import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/models/report.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

final _reportReasonsSub = {
  ReportReason.hate_speech: (String collection) =>
      'Someone $collection is using hate speech or slurs',
  ReportReason.violence: (String collection) =>
      'This $collection is violent or causing violence in your perspective',
  ReportReason.nudity: (String collection) =>
      'This $collection contains nudity or sexual activity',
  ReportReason.harassment: (String collection) =>
      'This $collection is harassing or bullying you or someone',
  ReportReason.spam: (String collection) =>
      'This $collection is a spam or spamming',
  ReportReason.fake: (String collection) =>
      'This $collection is fake or misleading',
  ReportReason.other: (String collection) => 'Something else',
};

final _reportReasonIcons = {
  ReportReason.hate_speech: Icons.sentiment_very_dissatisfied_outlined,
  ReportReason.violence: Icons.all_inclusive_outlined,
  ReportReason.nudity: Icons.nature_people_outlined,
  ReportReason.harassment: Icons.emoji_people_outlined,
  ReportReason.spam: Icons.line_axis_outlined,
  ReportReason.fake: Icons.warning_rounded,
  ReportReason.other: Icons.help_outline,
};

class ReportDialog extends HookConsumerWidget {
  final ReportCollection collection;
  final String recordId;
  const ReportDialog({
    Key? key,
    required this.collection,
    required this.recordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final selectedReason = useState<ReportReason>(ReportReason.hate_speech);
    final updating = useState(false);
    final error = useState<String?>(null);
    final mounted = useIsMounted();

    final descriptionController = useTextEditingController();

    return SimpleDialog(
      title: const Text('Report'),
      contentPadding: const EdgeInsets.all(16),
      insetPadding: const EdgeInsets.all(16),
      children: [
        Text(
          'Why do you want to report this ${collection.name}?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Card(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Gap(8),
              for (final reason in ReportReason.values)
                RadioListTile(
                  value: reason,
                  controlAffinity: ListTileControlAffinity.trailing,
                  groupValue: selectedReason.value,
                  onChanged: updating.value
                      ? null
                      : (ReportReason? value) {
                          if (value == null) return;
                          selectedReason.value = value;
                        },
                  secondary: Icon(
                    _reportReasonIcons[reason],
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(reason.formattedName),
                  subtitle: Text(
                    _reportReasonsSub[reason]!(collection.name),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedReason.value != ReportReason.other
                    ? null
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          maxLines: 5,
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Tell us more about this',
                            enabled: !updating.value,
                          ),
                        ),
                      ),
              ),
              if (error.value != null)
                Text(
                  error.value!,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              const Gap(8),
            ],
          ),
        ),
        const Gap(16),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const Gap(8),
            ElevatedButton(
              onPressed: updating.value
                  ? null
                  : () async {
                      try {
                        updating.value = true;
                        final report = Report.fromRecord(
                          await pb.collection('reports').create(
                            body: {
                              'collection': collection.name,
                              'record': recordId,
                              'reason': selectedReason.value.name,
                              'description': descriptionController.text,
                              'user': ref.read(authenticationProvider)?.id,
                            },
                          ),
                        );
                        if (mounted()) {
                          showSnackbar(
                            context,
                            'Reported ${collection.name}',
                            isDismissible: false,
                          );
                        }
                        error.value = null;
                        descriptionController.clear();
                        if (mounted()) Navigator.of(context).pop(report);
                      } on ClientException catch (e, stackTrace) {
                        error.value = e.response['message'];
                        Catcher.reportCheckedError(error, stackTrace);
                      } finally {
                        updating.value = false;
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange[400],
              ),
              child: const Text('Report'),
            ),
          ],
        )
      ],
    );
  }
}
