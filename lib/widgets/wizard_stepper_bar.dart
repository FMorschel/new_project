import 'package:flutter/material.dart';

import '../models/template_parameter.dart';

class WizardStepperBar extends StatelessWidget {
  const WizardStepperBar({
    required this.steps,
    required this.currentIndex,
    required this.answers,
    required this.onNavigateTo,
    super.key,
  });

  final List<TemplateParameter> steps;
  final int currentIndex;

  /// Current answer values keyed by parameter key. Used to determine
  /// whether a future step's prior required steps have been answered.
  final Map<String, Object?> answers;

  final ValueChanged<int> onNavigateTo;

  bool _isAnswered(TemplateParameter step) {
    var value = answers[step.key];
    if (value == null) return false;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true; // Bool is always answered.
  }

  bool _allPriorRequiredAnswered(int index) {
    for (var i = 0; i < index; i++) {
      if (steps[i].required && !_isAnswered(steps[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 8, top: 16),
            child: Text(
              'Steps',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          for (var i = 0; i < steps.length; i++)
            _StepChip(
              index: i,
              currentIndex: currentIndex,
              step: steps[i],
              isClickable:
                  i < currentIndex ||
                  (i > currentIndex && _allPriorRequiredAnswered(i)),
              onNavigateTo: onNavigateTo,
            ),
        ],
      ),
    ),
  );
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.index,
    required this.currentIndex,
    required this.step,
    required this.isClickable,
    required this.onNavigateTo,
  });

  final int index;
  final int currentIndex;
  final TemplateParameter step;
  final bool isClickable;
  final ValueChanged<int> onNavigateTo;

  @override
  Widget build(BuildContext context) {
    var isCurrent = index == currentIndex;
    var isPast = index < currentIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isClickable ? () => onNavigateTo(index) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isPast
                      ? Icons.check_circle
                      : (isCurrent ? Icons.edit : Icons.radio_button_unchecked),
                  size: 20,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : (isPast
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.label,
                    style: TextStyle(
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : (isClickable
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
