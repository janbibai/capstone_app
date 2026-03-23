import 'package:flutter/material.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<String> bookedSlots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.bookedSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  /// Generate 30-min interval slots from 08:00 to 16:30 (last appointment at 4:30 PM).
  List<String> get _allSlots {
    final slots = <String>[];
    for (int hour = 8; hour <= 16; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour < 16 || hour == 16) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }

  String _formatTo12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final slots = _allSlots;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isBooked = bookedSlots.contains(slot);
        final isSelected = selectedSlot == slot;

        return GestureDetector(
          onTap: isBooked ? null : () => onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.grey[200]
                  : isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBooked
                    ? Colors.grey[300]!
                    : isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _formatTo12Hour(slot),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isBooked
                    ? Colors.grey[400]
                    : isSelected
                        ? Colors.white
                        : Colors.black87,
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
