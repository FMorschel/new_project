import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  bool get _isSuccess => exitCode == 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: _isSuccess ? Colors.green : Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _isSuccess
                  ? 'Project created successfully!'
                  : 'Project creation failed.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (!_isSuccess) ...[
              const SizedBox(height: 8),
              Text('Exit code: $exitCode'),
            ],
            const SizedBox(height: 24),
            ExpansionTile(
              initiallyExpanded: !_isSuccess,
              title: const Text('Output Logs'),
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.topLeft,
                  child: SelectableText(
                    'stdout:\n$stdout\n\nstderr:\n$stderr',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Edit and retry'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: onClose, child: const Text('Close')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
