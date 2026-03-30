import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/template_parameter.dart';

class _SingleDotDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp('[^0-9.]'), '');
    var dotIndex = text.indexOf('.');
    var cleaned = dotIndex == -1
        ? text
        : text.substring(0, dotIndex + 1) +
              text.substring(dotIndex + 1).replaceAll('.', '');
    return newValue.copyWith(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}

class NumInputWidget extends StatefulWidget {
  const NumInputWidget({
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
  State<NumInputWidget> createState() => _NumInputWidgetState();
}

class _NumInputWidgetState extends State<NumInputWidget> {
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [_SingleDotDecimalFormatter()],
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
