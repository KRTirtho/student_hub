// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';

import 'package:ansi_styles/ansi_styles.dart';
import 'package:args/command_runner.dart';
import 'package:change_app_package_name/android_rename_steps.dart';
import 'package:collection/collection.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:interact/interact.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'flutterfire.dart';

class InitializeCommand extends Command {
  @override
  String get description =>
      "Initialize the students hub with your custom configuration";

  @override
  String get name => "init";

  void _updateProjectDartImports(String oldAppName, String appName) {
    final file = Directory("lib").listSync(recursive: true);

    for (final f in file) {
      if (f.path.endsWith(".dart")) {
        final file = File(f.path);
        final content = file.readAsStringSync();
        file.writeAsStringSync(
          content.replaceAll(
            "import 'package:$oldAppName/",
            "import 'package:$appName/",
          ),
        );
        print(AnsiStyles.dim("Updated imports of ${f.path}"));
      }
    }
  }

  String getCapBundleId(String bundleId) {
    return bundleId
        .split(".")
        .map(
          (e) => e
              .split("_")
              .mapIndexed((i, e) => i != 0 ? e.capitalize() : e)
              .join(""),
        )
        .join(".");
  }

  void _updateOldPackageNames(
    String oldBundleId,
    String oldDisplayName,
    String bundleId,
    String displayName,
  ) {
    final oldAppName = oldBundleId.split('.').last;
    final oldOrgName = oldBundleId.split('.').take(2).join('.');
    final appName = bundleId.split('.').last;
    final orgName = bundleId.split('.').take(2).join('.');
    // %{{APP_NAME}}
    final appNameFilePaths = {
      "ios/Runner/Info.plist": ["<string>%{{APP_NAME}}</string>"],
      "linux/CMakeLists.txt": ["set(BINARY_NAME \"%{{APP_NAME}}\")"],
      "macos/Runner/Configs/AppInfo.xcconfig": ["PRODUCT_NAME = %{{APP_NAME}}"],
      "macos/Runner.xcodeproj/project.pbxproj": [
        "includeInIndex = 0; path = \"%{{APP_NAME}}.app\"; sourceTree = BUILT_PRODUCTS_DIR; };",
        "33CC10ED2044A3C60003C045 /* %{{APP_NAME}}.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application;",
        "productReference = 33CC10ED2044A3C60003C045 /* %{{APP_NAME}}.app */",
        "33CC10ED2044A3C60003C045 /* %{{APP_NAME}}.app */",
      ],
      "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme": [
        "BuildableName = \"%{{APP_NAME}}.app\""
      ],
      "web/index.html": [
        "<meta name=\"apple-mobile-web-app-title\" content=\"%{{APP_NAME}}\">"
      ],
      "README.md": ["# %{{APP_NAME}}"],
      "windows/CMakeLists.txt": [
        "set(BINARY_NAME \"%{{APP_NAME}}\")",
        "project(%{{APP_NAME}} LANGUAGES CXX)"
      ],
      "windows/runner/Runner.rc": [
        'VALUE "OriginalFilename", "%{{APP_NAME}}.exe" "\\0"',
        'VALUE "InternalName", "%{{APP_NAME}}" "\\0"',
      ],
      "web/manifest.json": ['"short_name": "%{{APP_NAME}}",'],
    };
    // %{{APP_ID}}
    // %{{CAP_APP_ID}}
    final appIdFilePaths = {
      "linux/CMakeLists.txt": ['set(APPLICATION_ID "%{{APP_ID}}")'],
      "ios/Runner.xcodeproj/project.pbxproj": [
        'PRODUCT_BUNDLE_IDENTIFIER = %{{CAP_APP_ID}};'
      ],
      "macos/Runner/Configs/AppInfo.xcconfig": [
        'PRODUCT_BUNDLE_IDENTIFIER = %{{CAP_APP_ID}}'
      ]
    };

    // %{{DISPLAY_NAME}}
    final displayNameFilePaths = {
      "android/app/src/main/AndroidManifest.xml": [
        'android:label="%{{DISPLAY_NAME}}"'
      ],
      "linux/my_application.cc": [
        'gtk_window_set_title(window, "%{{DISPLAY_NAME}}");',
        'gtk_header_bar_set_title(header_bar, "%{{DISPLAY_NAME}}");'
      ],
      "ios/Runner/Info.plist": ['<string>%{{DISPLAY_NAME}}</string>'],
      "web/index.html": ['<title>%{{DISPLAY_NAME}}</title>'],
      "web/manifest.json": ['"name": "%{{DISPLAY_NAME}}",'],
      "windows/runner/main.cpp": [
        'if (!window.CreateAndShow(L"%{{DISPLAY_NAME}}", origin, size)) {'
      ],
      "windows/runner/Runner.rc": [
        'VALUE "FileDescription", "%{{DISPLAY_NAME}}" "\\0"',
        'VALUE "ProductName", "%{{DISPLAY_NAME}}" "\\0"'
      ],
      "lib/collections/env.dart": [
        "static const applicationDisplayName = \"%{{DISPLAY_NAME}}\";"
      ],
    };
    // %{{ORG_NAME}}
    final orgNameFilePaths = {
      "windows/runner/Runner.rc": [
        'VALUE "CompanyName", "%{{ORG_NAME}}" "\\0"',
        'VALUE "LegalCopyright", "Copyright (C) 2023 %{{ORG_NAME}}. All rights reserved." "\\0"'
      ],
      "macos/Runner/Configs/AppInfo.xcconfig": [
        'PRODUCT_COPYRIGHT = Copyright © 2023 %{{ORG_NAME}}. All rights reserved.'
      ]
    };

    for (final filePath in appNameFilePaths.entries) {
      final file = File(filePath.key);
      if (!file.existsSync()) continue;
      String content = file.readAsStringSync();
      for (final pattern in filePath.value) {
        content = content.replaceAll(
          pattern.replaceAll("%{{APP_NAME}}", oldAppName),
          pattern.replaceAll("%{{APP_NAME}}", appName),
        );
      }
      file.writeAsStringSync(content);
      print(AnsiStyles.dim("Updated ${file.path}"));
    }

    for (final filePath in appIdFilePaths.entries) {
      final file = File(filePath.key);
      if (!file.existsSync()) continue;
      String content = file.readAsStringSync();
      for (final pattern in filePath.value) {
        content = content.replaceAll(
          pattern.replaceAll("%{{APP_ID}}", oldBundleId),
          pattern.replaceAll("%{{APP_ID}}", bundleId),
        );
        content = content.replaceAll(
          pattern.replaceAll("%{{CAP_APP_ID}}", getCapBundleId(oldBundleId)),
          pattern.replaceAll("%{{CAP_APP_ID}}", getCapBundleId(bundleId)),
        );
      }
      file.writeAsStringSync(content);
      print(AnsiStyles.dim("Updated ${file.path}"));
    }

    for (final filePath in displayNameFilePaths.entries) {
      final file = File(filePath.key);
      if (!file.existsSync()) continue;
      String content = file.readAsStringSync();
      for (final pattern in filePath.value) {
        content = content.replaceAll(
          pattern.replaceAll("%{{DISPLAY_NAME}}", oldDisplayName),
          pattern.replaceAll("%{{DISPLAY_NAME}}", displayName),
        );
      }
      file.writeAsStringSync(content);
      print(AnsiStyles.dim("Updated ${file.path}"));
    }

    for (final filePath in orgNameFilePaths.entries) {
      final file = File(filePath.key);
      if (!file.existsSync()) continue;
      String content = file.readAsStringSync();
      for (final pattern in filePath.value) {
        content = content.replaceAll(
          pattern.replaceAll("%{{ORG_NAME}}", oldOrgName),
          pattern.replaceAll("%{{ORG_NAME}}", orgName),
        );
      }
      file.writeAsStringSync(content);
      print(AnsiStyles.dim("Updated ${file.path}"));
    }
  }

  String get _packageName {
    final buildGradle = File("android/app/build.gradle");

    final contents = buildGradle.readAsStringSync();

    final reg =
        RegExp('applicationId "(.*)"', caseSensitive: true, multiLine: false);

    return reg.firstMatch(contents)!.group(1)!;
  }

  String get _displayName {
    final buildGradle = File("android/app/src/main/AndroidManifest.xml");

    final contents = buildGradle.readAsStringSync();

    final reg =
        RegExp('android:label="(.*)"', caseSensitive: true, multiLine: false);

    return reg.firstMatch(contents)!.group(1)!;
  }

  void printFinalMessage() {
    print(AnsiStyles.green('Project setup completed successfully\n\n'));

    print(
      """You can now run the following commands to run the app:
        \$ flutter run -d chrome (for web browser. Requires Chrome to be installed)
        or,
        \$ flutter run -d ${Platform.operatingSystem} (for ${Platform.operatingSystem})
        
        In another terminal, run the following command to start the server:
        \$ pocketbase serve pb/pb_data
        """,
    );
  }

  @override
  void run() async {
    final Map<String, dynamic> config = {};
    final packageNameRegex =
        RegExp(r"^([A-Za-z]{1}[A-Za-z\d_]*\.)+[A-Za-z][A-Za-z\d_]*$");

    final applicationName = Input(
      prompt: 'Application name (e.g. com.example.app)',
      validator: (String value) {
        return packageNameRegex.hasMatch(value);
      },
      defaultValue: _packageName,
    ).interact();

    config['applicationName'] = applicationName;

    final displayName = Input(
      prompt: 'Display name (e.g. My App)',
      defaultValue: applicationName
          .split('.')
          .last
          .split('_')
          .map((e) => e.capitalize())
          .join(' '),
    ).interact();

    config['displayName'] = displayName;

    final description = Input(
      prompt: 'Description',
      defaultValue: 'The true Academic Social Media',
    ).interact();

    config['description'] = description;

    final version = Input(
      prompt: 'Version',
      defaultValue: '0.0.1',
      validator: (String value) {
        return RegExp(r"^\d+\.\d+\.\d+$").hasMatch(value);
      },
    ).interact();

    config['version'] = version;

    final oldApplicationName = _packageName;
    final oldDisplayName = _displayName;

    final pubspecFile = File('pubspec.yaml');
    final pubspec = YamlEditor(pubspecFile.readAsStringSync());

    pubspec.update(['name'], applicationName.split('.').last);
    pubspec.update(['description'], description);
    pubspec.update(['version'], version);

    pubspecFile.writeAsStringSync(pubspec.toString());

    print(AnsiStyles.dim("Updated pubspec.yaml"));

    try {
      if (oldDisplayName != displayName ||
          oldApplicationName != applicationName) {
        await AndroidRenameSteps(applicationName).process().then((_) async {
          _updateOldPackageNames(
            oldApplicationName,
            oldDisplayName,
            applicationName,
            displayName,
          );
          if (oldApplicationName != applicationName) {
            _updateProjectDartImports(
              oldApplicationName.split(".").last,
              applicationName.split(".").last,
            );
          }
          print(AnsiStyles.green('Successfully changed package name'));

          print(AnsiStyles.dim('> flutter pub get'));
          final flutterPubGetResult =
              await Process.run('flutter', ['pub', 'get']);
          if (flutterPubGetResult.exitCode != 0) {
            print(AnsiStyles.red('Failed to run flutter pub get'));
            print(AnsiStyles.dim(flutterPubGetResult.stderr));
            exit(1);
          }
        });
      }
    } catch (e, stack) {
      print(AnsiStyles.red('Failed to change package name'));
      print(AnsiStyles.dim(e.toString()));
      print(AnsiStyles.dim(stack.toString()));
      exit(1);
    }

    final generateImages = Confirm(
      prompt:
          "Do you want to Generate images?\n(You can change any files e.g logo, creator_profile etc in the ./assets directory. Change those before answering 'yes')",
      defaultValue: true,
    ).interact();

    config['generateImages'] = generateImages;

    if (config['generateImages'] == true) {
      await createIconsFromArguments([])
          .then((_) => createSplash(flavor: null, path: null));

      print(AnsiStyles.green('Images generated successfully'));
    }
    print(AnsiStyles.blue(
      'You can change any files e.g logo, creator_profile etc in the ./assets directory and run the `generate-images` command to regenerate the images\n\n',
    ));

    print(AnsiStyles.yellow("You've to login with your Firebase Account"));
    print(AnsiStyles.dim('> firebase login:ci --interactive'));

    final firebaseLoginResult =
        Process.runSync('firebase', ['login:ci', "--interactive"]);

    final token = (firebaseLoginResult.stdout as String)
        .split('\n')
        .firstWhereOrNull((element) => element.contains('1//'));

    if (token == null || firebaseLoginResult.exitCode != 0) {
      print(AnsiStyles.red('Firebase login failed'));
      print(AnsiStyles.dim(firebaseLoginResult.stdout));
      print(AnsiStyles.dim(firebaseLoginResult.stderr));
      exit(1);
    }
    print(AnsiStyles.dim(firebaseLoginResult.stdout));
    print(AnsiStyles.green('Firebase login successful'));

    await flutterFireRun(["configure", "--token", token]);

    print(AnsiStyles.green('Firebase configured successfully'));

    final configureGit = Confirm(
      prompt: "Do you want to configure git?",
      defaultValue: true,
    ).interact();

    if (!configureGit) {
      print(AnsiStyles.blue('Skipping git configuration'));
      printFinalMessage();
      exit(0);
    }

    Process.runSync('flutter', ['pub', 'get']);

    Process.runSync('git', ['remote', 'remove', 'origin']);

    final gitUrl = Input(
      prompt: 'Enter the github/gitlab url of your project',
      validator: (String value) {
        return RegExp(
                r"^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$")
            .hasMatch(value);
      },
    ).interact();

    final result = Process.runSync('git', ['remote', 'add', 'origin', gitUrl]);

    if (result.exitCode != 0) {
      print(AnsiStyles.red('Failed to add git remote'));
      print(AnsiStyles.dim(result.stderr));
    } else {
      print(AnsiStyles.green('Git remote added successfully'));
    }

    printFinalMessage();
  }
}
