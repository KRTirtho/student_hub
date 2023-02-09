import 'package:catcher/catcher.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

class VerificationPage extends HookConsumerWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final authNotifier = ref.watch(authenticationProvider.notifier);
    final error = useState<String?>(null);
    final mounted = useIsMounted();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Provide the verification number sent to your email (${authNotifier.state?.email})",
            ),
            const Gap(20),
            TextFormField(
              validator: (value) {
                if (value?.isNotEmpty != true) {
                  return "This is required buddy or robot!";
                }
                return null;
              },
              decoration: const InputDecoration(label: Text("Code")),
              onFieldSubmitted: (value) async {
                try {
                  await authNotifier.confirm(value);
                  error.value = null;
                  if (mounted()) GoRouter.of(context).go("/");
                } on ClientException catch (e, stack) {
                  error.value = e.response["message"];
                  Catcher.reportCheckedError(error, stack);
                }
              },
            ),
            const Gap(10),
            if (error.value != null)
              Text(
                error.value!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
