import 'package:student_hub/collections/assets.gen.dart';
import 'package:student_hub/collections/env.dart';
import 'package:student_hub/collections/logo.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "About ${Env.applicationDisplayName}",
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Image.asset(
                  getLogoPath(context),
                  height: 200,
                  width: 200,
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Central source of information and co-learning platform for EUSCians.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      const Card(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text("Version"),
                          subtitle: Text("v1.0.0"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Credits",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontSize: 18),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          leading: CircleAvatar(
                            backgroundImage: Assets.creators.tirtho.provider(),
                          ),
                          onTap: () {
                            launchUrlString(
                              "https://github.com/KRTirtho",
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          title: const Text("Kingkor Roy Tirtho"),
                          subtitle: const Text("Author, Developer, Concept"),
                          trailing: const Icon(Icons.code),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          leading: CircleAvatar(
                            backgroundImage: Assets.creators.farabi.provider(),
                          ),
                          onTap: () {
                            launchUrlString(
                              "https://www.facebook.com/farabi.2004",
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          title: const Text("S.M Khan Farabi"),
                          subtitle:
                              const Text("Concept, Planning, Presentation"),
                          trailing: const Icon(Icons.app_registration_rounded),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          leading: CircleAvatar(
                            backgroundImage: Assets.creators.souad.provider(),
                          ),
                          onTap: () {
                            launchUrlString(
                              "https://www.facebook.com/fss.shadik",
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          title: const Text("Farhan Saadik Souad"),
                          subtitle: const Text("Visuals, Presentation"),
                          trailing: const Icon(Icons.brush_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Made with ?????? in BUET College, Bangladesh????????\nCopyright ?? 2023 ${Env.applicationDisplayName}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
