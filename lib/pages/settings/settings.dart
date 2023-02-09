import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:student_hub/components/scrolling/constrained_list_view.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final authNotifier = ref.watch(authenticationProvider.notifier);
    final isLoggedIn = ref.watch(authenticationProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ConstrainedListView(
        constraints: const BoxConstraints(maxWidth: 1080),
        alignment: Alignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text("Theme"),
            trailing: DropdownButton<AdaptiveThemeMode>(
              value: AdaptiveTheme.of(context).mode,
              onChanged: (value) {
                if (value != null) {
                  AdaptiveTheme.of(context).setThemeMode(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: AdaptiveThemeMode.light,
                  child: Text("Light"),
                ),
                DropdownMenuItem(
                  value: AdaptiveThemeMode.dark,
                  child: Text("Dark"),
                ),
                DropdownMenuItem(
                  value: AdaptiveThemeMode.system,
                  child: Text("System"),
                ),
              ],
            ),
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                authNotifier.logout();
                GoRouter.of(context).go('/login');
              },
            ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About"),
            onTap: () {
              GoRouter.of(context).push('/settings/about');
            },
          ),
        ],
      ),
    );
  }
}
