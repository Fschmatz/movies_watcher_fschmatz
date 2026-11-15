import 'package:flutter/material.dart';

import '../enum/watch_list_filter.dart';

class WatchListFilterChips extends StatefulWidget {
  final WatchListFilter selectedFilter;
  final ValueChanged<WatchListFilter> onFilterChanged;

  const WatchListFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<WatchListFilterChips> createState() => _WatchListFilterChipsState();
}

class _WatchListFilterChipsState extends State<WatchListFilterChips> {
  late WatchListFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.selectedFilter;
  }

  @override
  void didUpdateWidget(covariant WatchListFilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFilter != oldWidget.selectedFilter) {
      _currentFilter = widget.selectedFilter;
    }
  }

  void _handleFilterSelected(WatchListFilter filter) {
    if (filter == _currentFilter) return;
    setState(() {
      _currentFilter = filter;
    });
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) {
        widget.onFilterChanged(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool hasRuntimeSelected = _currentFilter.isRuntimeFilter;
    final String selectedRuntimeLabel = hasRuntimeSelected ? _currentFilter.label : 'Runtime';

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
              labelPadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
              selected: _currentFilter == WatchListFilter.all,
              onSelected: (selected) {
                _handleFilterSelected(WatchListFilter.all);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Favorites'),
              labelPadding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
              selected: _currentFilter == WatchListFilter.favorites,
              onSelected: (selected) {
                _handleFilterSelected(selected ? WatchListFilter.favorites : WatchListFilter.all);
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
                      Icon(controller.isOpen ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, color: colorScheme.onSurfaceVariant),
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
                  final isSelected = _currentFilter == option;
                  return MenuItemButton(
                    leadingIcon: Icon(
                      isSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _handleFilterSelected(option),
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
