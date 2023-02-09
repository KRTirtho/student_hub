import 'package:args/command_runner.dart';

import 'initialize_command.dart';

void main(List<String> args) {
  final commandRunner = CommandRunner('init', 'Initialize the project')
    ..addCommand(InitializeCommand());

  commandRunner.run(args);
}
