import 'package:flutter/material.dart';

/// Single item descriptor for the CompactFilterBar
class FilterDropdownItem<T> {
  final String label;
  final T? value;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onChanged;
  final IconData? icon;

  const FilterDropdownItem({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
  });
}

class FilterOption<T> {
  final String label;
  final T? value;
  final IconData? icon;
  final Color? color;

  const FilterOption({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}

/// A space-saving, sleek horizontal dropdown filter bar.
/// Replaces multi-row chips and heavy filter panels, fitting cleanly in 38px height.
class CompactFilterBar extends StatelessWidget {
  final List<FilterDropdownItem<dynamic>> items;
  final VoidCallback? onReset;
  final bool hasActiveFilters;
  final EdgeInsetsGeometry padding;

  const CompactFilterBar({
    super.key,
    required this.items,
    this.onReset,
    this.hasActiveFilters = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _buildDropdownPill(context, items[index]);
                },
              ),
            ),
            if (hasActiveFilters && onReset != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onReset,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.close_rounded, size: 14, color: Color(0xFFEF4444)),
                      SizedBox(width: 4),
                      Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownPill(BuildContext context, FilterDropdownItem<dynamic> item) {
    // Find current label
    final selectedOption = item.options.firstWhere(
      (opt) => opt.value == item.value,
      orElse: () => item.options.first,
    );
    final isFiltered = item.value != null &&
        item.value != '' &&
        item.value != 'All' &&
        item.value != 'All Departments' &&
        item.value != 'All Tasks' &&
        item.value != 'All Stages' &&
        item.value != 'All Statuses';

    return PopupMenuButton<dynamic>(
      initialValue: item.value,
      tooltip: item.label,
      elevation: 6,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      onSelected: item.onChanged,
      itemBuilder: (BuildContext context) {
        return item.options.map((option) {
          final isSelected = option.value == item.value;
          return PopupMenuItem<dynamic>(
            value: option.value,
            height: 40,
            child: Row(
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 16,
                    color: option.color ?? (isSelected ? const Color(0xFF212529) : const Color(0xFF64748B)),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF212529) : const Color(0xFF334155),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_rounded, size: 16, color: Color(0xFF212529)),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isFiltered ? const Color(0xFF212529) : const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFiltered ? const Color(0xFF212529) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isFiltered
              ? [
                  BoxShadow(
                    color: const Color(0xFF212529).withOpacity(0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 14,
                color: isFiltered ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                selectedOption.label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isFiltered ? FontWeight.w700 : FontWeight.w600,
                  color: isFiltered ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isFiltered ? Colors.white70 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
