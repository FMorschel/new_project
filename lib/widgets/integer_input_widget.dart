import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/template_parameter.dart';

class IntegerInputWidget extends StatefulWidget {
  const IntegerInputWidget({
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
  State<IntegerInputWidget> createState() => _IntegerInputWidgetState();
}

class _IntegerInputWidgetState extends State<IntegerInputWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _controller,
        enabled: widget.isActive,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: widget.parameter.label),
        onChanged: widget.onChanged,
      ),
      if (widget.parameter.description != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(widget.parameter.description!),
        ),
      if (!widget.isActive && widget.disabledExplanation != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(widget.disabledExplanation!),
        ),
    ],
  );
}
