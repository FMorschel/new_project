import 'package:flutter/material.dart';

import '../models/template_parameter.dart';

class MultiOptionsInputWidget extends StatefulWidget {
  const MultiOptionsInputWidget({
    required this.parameter,
    required this.onChanged,
    super.key,
    this.isActive = true,
    this.disabledExplanation,
    this.initialValue = const [],
  });

  final TemplateParameter parameter;
  final ValueChanged<List<String>> onChanged;
  final bool isActive;
  final String? disabledExplanation;
  final List<String> initialValue;

  @override
  State<MultiOptionsInputWidget> createState() =>
      _MultiOptionsInputWidgetState();
}

class _MultiOptionsInputWidgetState extends State<MultiOptionsInputWidget> {
  bool _isOpen = false;
  late List<String> _selected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List.of(widget.initialValue);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    var query = _searchController.text.toLowerCase();
    return (widget.parameter.options ?? [])
        .where((o) => o.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(String option) {
    setState(() {
      if (_selected.contains(option)) {
        _selected.remove(option);
      } else {
        _selected
          ..add(option)
          ..sort(
            (a, b) => (widget.parameter.options ?? [])
                .indexOf(a)
                .compareTo((widget.parameter.options ?? []).indexOf(b)),
          );
      }
    });
    widget.onChanged(List.of(_selected));
  }

  String get _summary =>
      _selected.isEmpty ? widget.parameter.label : _selected.join(', ');

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton(
        onPressed: widget.isActive
            ? () => setState(() => _isOpen = !_isOpen)
            : null,
        child: Row(
          children: [
            Expanded(child: Text(_summary)),
            Icon(_isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          ],
        ),
      ),
      if (_isOpen) ...[
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search...'),
          onChanged: (_) => setState(() {}),
        ),
        ..._filtered.map(
          (option) => CheckboxListTile(
            title: Text(option),
            value: _selected.contains(option),
            onChanged: (_) => _toggle(option),
          ),
        ),
      ],
      if (!widget.isActive && widget.disabledExplanation != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(widget.disabledExplanation!),
        ),
    ],
  );
}
