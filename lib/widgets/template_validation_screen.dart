import 'dart:async';

import 'package:flutter/material.dart';

class TemplateValidationScreen extends StatefulWidget {
  const TemplateValidationScreen({
    required this.validationTask,
    required this.onSuccess,
    required this.onClose,
    super.key,
  });

  final Future<void> validationTask;
  final VoidCallback onSuccess;
  final VoidCallback onClose;

  @override
  State<TemplateValidationScreen> createState() =>
      _TemplateValidationScreenState();
}

class _TemplateValidationScreenState extends State<TemplateValidationScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_validate());
  }

  Future<void> _validate() async {
    try {
      await widget.validationTask;
      if (mounted) {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Template Validation Failed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: widget.onClose, child: const Text('Close')),
        ],
      ),
    );
  }
}
