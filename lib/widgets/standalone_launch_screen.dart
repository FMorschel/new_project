import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StandaloneLaunchScreen extends StatefulWidget {
  const StandaloneLaunchScreen({
    required this.templates,
    required this.templatePaths,
    required this.onContinue,
    required this.pickFolder,
    super.key,
  });

  final List<String> templates;
  final Map<String, String> templatePaths;
  final void Function(String folderPath, String templateName) onContinue;
  final Future<String?> Function() pickFolder;

  @override
  State<StandaloneLaunchScreen> createState() => _StandaloneLaunchScreenState();
}

class _StandaloneLaunchScreenState extends State<StandaloneLaunchScreen> {
  String? _selectedFolder;
  String? _selectedTemplate;

  bool get _canContinue => _selectedFolder != null && _selectedTemplate != null;

  Future<void> _onPickFolder() async {
    var path = await widget.pickFolder();
    if (path != null) {
      setState(() => _selectedFolder = path);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create New Project',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        Text(
          'Project Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            onTap: _onPickFolder,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _selectedFolder ?? 'Select a destination folder...',
                      style: TextStyle(
                        color: _selectedFolder == null
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _onPickFolder,
                    icon: const Icon(Icons.snippet_folder_outlined),
                    label: const Text('Browse'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Choose a Template',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            elevation: 0,
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              children: [
                if (widget.templates.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No templates found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please add some templates to continue.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder(
                          future: getApplicationCacheDirectory(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            var cacheDir = snapshot.data!;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                border: Border.fromBorderSide(
                                  BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: SelectableText(
                                      'Add to: ${p.join(cacheDir.path, 'templates')}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    iconSize: 18,
                                    icon: const Icon(Icons.copy),
                                    tooltip: 'Copy path',
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: cacheDir.path),
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Path copied to clipboard',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                for (final name in widget.templates) ...[
                  () {
                    var path = widget.templatePaths[name];
                    var iconPath = path != null
                        ? p.join(path, 'icon.ico')
                        : null;
                    var hasIcon =
                        iconPath != null && File(iconPath).existsSync();

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: hasIcon
                            ? ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child: Image.file(
                                  File(iconPath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.folder_outlined),
                                ),
                              )
                            : Icon(
                                Icons.folder_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: path != null
                          ? Text(
                              path,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      selected: name == _selectedTemplate,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                      onTap: () => setState(() => _selectedTemplate = name),
                      trailing: name == _selectedTemplate
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    );
                  }(),
                  if (name != widget.templates.last)
                    const Divider(height: 1, indent: 88),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
              ),
              onPressed: _canContinue
                  ? () =>
                        widget.onContinue(_selectedFolder!, _selectedTemplate!)
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
