class LaunchArgs {
  const LaunchArgs({this.folderPath, this.templateName});

  factory LaunchArgs.parse(List<String> args) {
    if (args.length < 2) return const LaunchArgs();
    return LaunchArgs(folderPath: args.first, templateName: args[1]);
  }

  final String? folderPath;
  final String? templateName;
}
