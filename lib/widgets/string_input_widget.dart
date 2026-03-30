import 'package:flutter/material.dart';

import '../models/template_parameter.dart';

class StringInputWidget extends StatefulWidget {
  const StringInputWidget({
    required this.parameter,
    required this.onChanged,
    super.key,
    this.isActive = true,
    this.disabledExplanation,
    this.initialValue,
  });

  final TemplateParameter parameter;
  final ValueChanged<String?> onChanged;
  final bool isActive;
  final String? disabledExplanation;
  final String? initialValue;

  @override
  State<StringInputWidget> createState() => _StringInputWidgetState();
}

class _StringInputWidgetState extends State<StringInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.parameter.label,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      if (widget.parameter.description != null)
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Text(
            widget.parameter.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
      else
        const SizedBox(height: 24),
      TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.isActive,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: widget.isActive
              ? Theme.of(context).colorScheme.surface
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          hintText: 'Enter ${widget.parameter.label.toLowerCase()}',
        ),
        onChanged: widget.onChanged,
      ),
      if (!widget.isActive && widget.disabledExplanation != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.disabledExplanation!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
