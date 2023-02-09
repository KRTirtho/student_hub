import 'package:student_hub/components/image/avatar.dart';
import 'package:student_hub/models/user.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/utils/number_ending_type.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserCard extends HookConsumerWidget {
  final User user;
  const UserCard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 200),
      child: Card(
        child: InkWell(
          onTap: () {
            if (user.id == ref.read(authenticationProvider)?.id) {
              GoRouter.of(context).go(
                "/profile/authenticated",
              );
            } else {
              GoRouter.of(context).push(
                "/profile/${user.id}",
              );
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              const Gap(16),
              Avatar(user: user, radius: 40),
              const Gap(10),
              Text(user.name ?? user.username),
              Text(
                user.isMaster == true
                    ? "${user.currentSession?.subject?.formattedName} Teacher since ${user.currentSession?.year}"
                    : "B. ${user.currentSession?.year}'s  ${user.currentSession?.serial}${getNumberEnding(user.currentSession?.serial ?? 999)} of C. ${user.currentSession?.standard}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
