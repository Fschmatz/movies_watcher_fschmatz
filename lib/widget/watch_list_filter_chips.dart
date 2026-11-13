import 'package:flutter/material.dart';

import '../enum/watch_list_filter.dart';

class WatchListFilterChips extends StatelessWidget {
  final WatchListFilter selectedFilter;
  final ValueChanged<WatchListFilter> onFilterChanged;

  const WatchListFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasRuntimeSelected = selectedFilter.isRuntimeFilter;
    final String selectedRuntimeLabel = hasRuntimeSelected ? selectedFilter.label : 'Runtime';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedFilter == WatchListFilter.all,
                onSelected: (selected) {
                  onFilterChanged(WatchListFilter.all);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Favorites'),
                selected: selectedFilter == WatchListFilter.favorites,
                onSelected: (selected) {
                  onFilterChanged(selected ? WatchListFilter.favorites : WatchListFilter.all);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: MenuAnchor(
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return FilterChip(
                    labelPadding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(selectedRuntimeLabel),
                        const SizedBox(width: 4),
                        Icon(
                          controller.isOpen ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined,
                        ),
                      ],
                    ),
                    selected: hasRuntimeSelected,
                    onSelected: (_) {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
                menuChildren: [
                  ...WatchListFilter.runtimeFilters.map((option) {
                    final isSelected = selectedFilter == option;
                    return MenuItemButton(
                      leadingIcon: Icon(
                        isSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => onFilterChanged(option),
                      child: Text(option.label),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
  }
}
