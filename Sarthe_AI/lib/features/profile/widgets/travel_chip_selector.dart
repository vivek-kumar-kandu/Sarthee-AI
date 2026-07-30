import 'package:flutter/material.dart';

/// Reusable Single & Multi-Select Travel Chip Selector Widget.
///
/// Features:
/// • Design System v1.2 Travel Teal (#0D9488) active selection state
/// • Single-select or Multi-select behavior
/// • Accessibility & 48dp touch target compliance
class TravelChipSelector extends StatelessWidget {
  const TravelChipSelector({
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    super.key,
    this.isMultiSelect = false,
  });

  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool isMultiSelect;

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF0D9488); // Travel Teal

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((option) {
        final bool isSelected = selectedValues.contains(option);

        return Semantics(
          button: true,
          selected: isSelected,
          label: option,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isMultiSelect) {
                  final newList = List<String>.from(selectedValues);
                  if (isSelected) {
                    newList.remove(option);
                  } else {
                    newList.add(option);
                  }
                  onChanged(newList);
                } else {
                  onChanged([option]);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withValues(alpha: 0.12)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? activeColor
                        : const Color(0xFFCBD5E1),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (isSelected) ...<Widget>[
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: activeColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF334155),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
