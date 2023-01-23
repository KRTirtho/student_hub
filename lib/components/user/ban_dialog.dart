import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/user.dart';
import 'package:eusc_freaks/utils/snackbar.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

final _banReasonsSub = {
  UserBanReason.hate_speech: (String name) =>
      '$name has used hate speech or slurs',
  UserBanReason.violence: (String name) =>
      '$name has caused violent in your perspective',
  UserBanReason.nudity: (String name) =>
      '$name has posted nudity or sexual content',
  UserBanReason.harassment: (String name) =>
      '$name is harassing or bullying you or someone',
  UserBanReason.spam: (String name) =>
      '$name is spamming or posting irrelevant content',
  UserBanReason.fake: (String name) => '$name is pretending to be someone else',
};

final _banReasonIcons = {
  UserBanReason.hate_speech: Icons.sentiment_very_dissatisfied_outlined,
  UserBanReason.violence: Icons.all_inclusive_outlined,
  UserBanReason.nudity: Icons.nature_people_outlined,
  UserBanReason.harassment: Icons.emoji_people_outlined,
  UserBanReason.spam: Icons.line_axis_outlined,
  UserBanReason.fake: Icons.warning_rounded,
};

class BanDialog extends HookConsumerWidget {
  final User user;
  const BanDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final selectedReasons = useState<List<UserBanReason>>([]);
    final bannedFor = useState<int>(3);
    final error = useState<String?>(null);
    final updating = useState(false);
    final mounted = useIsMounted();

    return SimpleDialog(
      title: const Text(
        'Ban user',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(16),
      children: [
        const Text("Ban duration"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text("3 days"),
              selected: bannedFor.value == 3,
              labelStyle: bannedFor.value == 3
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 3;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("1 week"),
              selected: bannedFor.value == 7,
              labelStyle: bannedFor.value == 7
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 7;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("15 days"),
              selected: bannedFor.value == 15,
              labelStyle: bannedFor.value == 15
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 15;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("1 month"),
              selected: bannedFor.value == 30,
              labelStyle: bannedFor.value == 30
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 30;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("3 months"),
              selected: bannedFor.value == 90,
              labelStyle: bannedFor.value == 90
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 90;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("1 year"),
              selected: bannedFor.value == 365,
              labelStyle: bannedFor.value == 365
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 365;
                      }
                    },
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text("Lifetime"),
              selected: bannedFor.value == 365 * 100,
              labelStyle: bannedFor.value == 365 * 100
                  ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
                  : null,
              onSelected: updating.value
                  ? null
                  : (value) {
                      if (value) {
                        bannedFor.value = 365 * 100;
                      }
                    },
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("Why do you want to ban this user?"),
        ),
        const Gap(16),
        Card(
          child: Column(
            children: [
              for (final reason in UserBanReason.values)
                CheckboxListTile(
                  value: selectedReasons.value.contains(reason),
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: updating.value
                      ? null
                      : (value) {
                          if (value == null) return;
                          if (value) {
                            selectedReasons.value = [
                              ...selectedReasons.value,
                              reason
                            ];
                          } else {
                            selectedReasons.value = selectedReasons.value
                                .where((element) => element != reason)
                                .toList();
                          }
                        },
                  secondary: Icon(
                    _banReasonIcons[reason],
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(reason.formattedName),
                  subtitle: Text(
                    _banReasonsSub[reason]!(user.name ?? user.username),
                    style: Theme.of(context).textTheme.caption,
                  ),
                )
            ],
          ),
        ),
        if (error.value != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              error.value!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
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
                        await pb.collection("users").update(
                          user.id,
                          body: {
                            "ban_until": DateTime.now()
                                .add(Duration(days: bannedFor.value))
                                .toIso8601String(),
                            "ban_reason": selectedReasons.value
                                .map((e) => e.name)
                                .toList(),
                            "banned_by": ref.read(authenticationProvider)?.id,
                          },
                        );
                        if (mounted()) {
                          showSnackbar(
                            context,
                            'Banned ${user.name}',
                            isDismissible: false,
                          );
                        }
                        error.value = null;
                        selectedReasons.value = [];
                        bannedFor.value = 3;
                        if (mounted()) {
                          Navigator.of(context).pop();
                          QueryBowl.of(context)
                              .getQuery(userQueryJob(user.id).queryKey)
                              ?.refetch();
                        }
                      } on ClientException catch (e) {
                        error.value = e.response['message'];
                      } finally {
                        updating.value = false;
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
              ),
              child: Text('Ban (${bannedFor.value} days)'),
            ),
          ],
        )
      ],
    );
  }
}
