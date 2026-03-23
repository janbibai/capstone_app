import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.labels = const ['Date & Time', 'Patient Info', 'Confirm'],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          // Even indices are circles, odd indices are lines
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final isActive = stepIndex <= currentStep;
            final isCurrent = stepIndex == currentStep;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 36 : 30,
                  height: isCurrent ? 36 : 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: isCurrent ? 16 : 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[stepIndex],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[500],
                  ),
                ),
              ],
            );
          } else {
            // Connector line
            final beforeStep = index ~/ 2;
            final isCompleted = beforeStep < currentStep;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}
