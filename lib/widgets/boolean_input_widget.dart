import 'package:flutter/material.dart';
import '../models/template_parameter.dart';

class BooleanInputWidget extends StatefulWidget {
  const BooleanInputWidget({
    required this.parameter,
    required this.onChanged,
    super.key,
    this.isActive = true,
    this.disabledExplanation,
    this.initialValue = false,
  });

  final TemplateParameter parameter;
  final ValueChanged<bool> onChanged;
  final bool isActive;
  final String? disabledExplanation;
  final bool initialValue;

  @override
  State<BooleanInputWidget> createState() => _BooleanInputWidgetState();
}

class _BooleanInputWidgetState extends State<BooleanInputWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CheckboxListTile(
        title: Text(widget.parameter.label),
        value: _value,
        enabled: widget.isActive,
        onChanged: widget.isActive
            ? (v) {
                setState(() => _value = v ?? false);
                widget.onChanged(_value);
              }
            : null,
      ),
      if (!widget.isActive && widget.disabledExplanation != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(widget.disabledExplanation!),
        ),
    ],
  );
}
