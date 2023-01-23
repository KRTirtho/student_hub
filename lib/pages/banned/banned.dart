import 'dart:io';

import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/hooks/use_redirect.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _banReasonsSub = {
  UserBanReason.hate_speech: 'You\'ve used hate speech in the community',
  UserBanReason.violence:
      'You\'ve created or caused violence among other users',
  UserBanReason.nudity: 'You\'ve posted nudity or sexual content',
  UserBanReason.harassment:
      'You\'ve harassed other users or caused them to be harassed',
  UserBanReason.spam: 'You\'ve spammed the community',
  UserBanReason.fake:
      'You\'ve created a fake account or used a fake name to mislead other users',
};

final _banReasonIcons = {
  UserBanReason.hate_speech: Icons.sentiment_very_dissatisfied_outlined,
  UserBanReason.violence: Icons.all_inclusive_outlined,
  UserBanReason.nudity: Icons.nature_people_outlined,
  UserBanReason.harassment: Icons.emoji_people_outlined,
  UserBanReason.spam: Icons.line_axis_outlined,
  UserBanReason.fake: Icons.warning_rounded,
};

class BannedPage extends HookConsumerWidget {
  const BannedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final user = ref.watch(authenticationProvider);

    useRedirect(
      "/",
      user?.isBanned != true,
    );

    return Scaffold(
      body: ConstrainedListView(
        constraints: const BoxConstraints(maxWidth: 800),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        children: [
          const Gap(60),
          CircleAvatar(
            radius: 50,
            backgroundImage: UniversalImage.imageProvider(
              user!.getAvatarURL(const Size(0, 100)).toString(),
            ),
            child: Icon(
              Icons.block_outlined,
              size: 90,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Text(
            "Banned!",
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          Text(
            "You have been banned from using EUSC Hub for ${user.bannedUntil?.difference(DateTime.now()).inDays} days (Until ${user.bannedUntil?.toLocal().toString().split(' ')[0]})",
          ),
          const Gap(10),
          Text(
            "Why have I been banned?",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(10),
          for (final reason in user.banReason)
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(_banReasonIcons[reason]),
                title: Text(_banReasonsSub[reason]!),
              ),
            ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text("Exit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
