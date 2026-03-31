import 'package:flutter/material.dart';

import '../models/template_parameter.dart';

class SingleOptionsInputWidget extends StatefulWidget {
  const SingleOptionsInputWidget({
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
  State<SingleOptionsInputWidget> createState() =>
      _SingleOptionsInputWidgetState();
}

class _SingleOptionsInputWidgetState extends State<SingleOptionsInputWidget> {
  bool _isOpen = false;
  String? _selected;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
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

  void _selectOption(String option) {
    setState(() {
      _selected = option;
      _isOpen = false;
      _searchController.clear();
    });
    widget.onChanged(option);
  }

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
            Expanded(child: Text(_selected ?? widget.parameter.label)),
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
          (option) =>
              ListTile(title: Text(option), onTap: () => _selectOption(option)),
        ),
        if (!widget.parameter.required && _searchController.text.isEmpty)
          ListTile(
            title: const Text('<None>'),
            onTap: () {
              setState(() {
                _selected = null;
                _isOpen = false;
                _searchController.clear();
              });
              widget.onChanged(null);
            },
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
