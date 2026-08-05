import 'dart:io';

String? readOption(List<String> arguments, String name) {
  final prefix = '$name=';

  for (final argument in arguments) {
    if (argument.startsWith(prefix)) {
      return argument.substring(prefix.length);
    }
  }

  return null;
}

bool hasEnabledFlag(List<String> arguments, String name) {
  return arguments.any(
    (argument) => argument == name || argument == '$name=true',
  );
}

Never fail(String message) {
  stderr.writeln(message);
  exit(1);
}

Future<ProcessResult> runGit(
  List<String> arguments, {
  required String workingDirectory,
  bool printOutput = true,
}) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: workingDirectory,
    runInShell: Platform.isWindows,
  );

  if (printOutput) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }

  return result;
}

Future<void> runGitOrFail(
  List<String> arguments, {
  required String workingDirectory,
}) async {
  final result = await runGit(arguments, workingDirectory: workingDirectory);

  if (result.exitCode != 0) {
    fail('Git command failed: git ${arguments.join(' ')}');
  }
}

Future<void> main(List<String> arguments) async {
  final branch = readOption(arguments, '--branch');
  final message = readOption(arguments, '--msg');
  final repositoryPath =
      readOption(arguments, '--repo-path') ?? Directory.current.path;
  final baseBranch = readOption(arguments, '--pull-branch') ?? 'test';
  final shouldPullFromBase =
      hasEnabledFlag(arguments, '--pull-from-test') ||
      hasEnabledFlag(arguments, '--pull-from-dev');

  if (branch == null || branch.isEmpty) {
    fail('Parameter --branch is required.');
  }

  final repository = Directory(repositoryPath);
  if (!repository.existsSync()) {
    fail('Repository path does not exist: $repositoryPath');
  }

  final timestamp = DateTime.now()
      .toIso8601String()
      .substring(0, 16)
      .replaceAll(RegExp(r'[-:T]'), '');
  final commitMessage =
      '${message?.isNotEmpty == true ? message : 'Auto commit'} - $timestamp';

  stdout.writeln(
    'Changing to repository directory: ${repository.absolute.path}',
  );
  await runGitOrFail([
    'checkout',
    branch,
  ], workingDirectory: repository.absolute.path);

  final status = await runGit(
    ['status', '--porcelain'],
    workingDirectory: repository.absolute.path,
    printOutput: false,
  );
  if (status.exitCode != 0) {
    stderr.write(status.stderr);
    fail('Could not read repository status.');
  }

  if (status.stdout.toString().trim().isNotEmpty) {
    stdout.writeln('Changes detected. Adding files...');
    await runGitOrFail([
      'add',
      '.',
    ], workingDirectory: repository.absolute.path);

    stdout.writeln('Committing: "$commitMessage"');
    await runGitOrFail([
      'commit',
      '-m',
      commitMessage,
    ], workingDirectory: repository.absolute.path);
  } else {
    stdout.writeln('No changes to commit.');
  }

  if (shouldPullFromBase) {
    stdout.writeln('Pulling latest changes from [$baseBranch]...');
    final pullResult = await runGit([
      'pull',
      'origin',
      baseBranch,
    ], workingDirectory: repository.absolute.path);

    if (pullResult.exitCode != 0) {
      fail(
        'Merge conflict when pulling from $baseBranch. Please resolve manually.',
      );
    }
  }

  final branchStatus = await runGit(
    ['status', '-sb'],
    workingDirectory: repository.absolute.path,
    printOutput: false,
  );
  if (branchStatus.exitCode != 0) {
    stderr.write(branchStatus.stderr);
    fail('Could not read branch status.');
  }

  final aheadMatch = RegExp(
    r'ahead (\d+)',
  ).firstMatch(branchStatus.stdout.toString());
  final aheadCount = int.tryParse(aheadMatch?.group(1) ?? '') ?? 0;

  if (aheadCount > 0) {
    stdout.writeln('Pushing $aheadCount commit(s) to origin/$branch...');
    await runGitOrFail([
      'push',
      'origin',
      'HEAD:$branch',
    ], workingDirectory: repository.absolute.path);
    stdout.writeln('Changes pushed successfully.');
  } else {
    stdout.writeln('No new commits to push.');
  }
}
