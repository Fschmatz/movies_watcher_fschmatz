import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

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
  final GlobalKey _groupKey = GlobalKey();

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

  int get _selectedIndex {
    if (_currentFilter == WatchListFilter.favorites) return 1;
    if (_currentFilter.isRuntimeFilter) return 2;
    return 0;
  }

  Future<void> _showRuntimeMenu(BuildContext context) async {
    final RenderBox? renderBox = _groupKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final Offset buttonBottomRight = renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay);

    final double left = buttonTopLeft.dx + (renderBox.size.width * 0.45);
    final RelativeRect position = RelativeRect.fromLTRB(
      left,
      buttonBottomRight.dy + 6,
      overlay.size.width - buttonBottomRight.dx,
      overlay.size.height - (buttonBottomRight.dy + 6),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasRuntimeSelected = _currentFilter.isRuntimeFilter;

    final selected = await showMenu<WatchListFilter?>(
      context: context,
      position: position,
      color: colorScheme.surfaceContainerHigh,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: [
        if (hasRuntimeSelected) ...[
          PopupMenuItem<WatchListFilter?>(
            value: WatchListFilter.all,
            child: Row(
              children: [
                Icon(Icons.clear_rounded, size: 20, color: colorScheme.error),
                const SizedBox(width: 12),
                Text(
                  'Clear filter',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
        ],
        ...WatchListFilter.runtimeFilters.map((filter) {
          final isSelected = _currentFilter == filter;
          return PopupMenuItem<WatchListFilter?>(
            value: filter,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    if (selected != null) {
      _handleFilterSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRuntimeSelected = _currentFilter.isRuntimeFilter;
    final String runtimeLabel = hasRuntimeSelected ? _currentFilter.label : 'Runtime';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        key: _groupKey,
        child: M3EToggleButtonGroup(
          type: M3EButtonGroupType.connected,
          selectedIndex: _selectedIndex,
          onSelectedIndexChanged: (index) {
            if (index == 0) {
              _handleFilterSelected(WatchListFilter.all);
            } else if (index == 1) {
              _handleFilterSelected(WatchListFilter.favorites);
            } else if (index == 2) {
              _showRuntimeMenu(context);
            } else if (index == null) {
              if (hasRuntimeSelected) {
                _showRuntimeMenu(context);
              } else {
                _handleFilterSelected(WatchListFilter.all);
              }
            }
          },
          actions: [
            const M3EToggleButtonGroupAction(
              label: Text('All'),
              icon: Icon(Icons.movie_outlined),
              checkedIcon: Icon(Icons.movie),
            ),
            const M3EToggleButtonGroupAction(
              label: Text('Favorites'),
              icon: Icon(Icons.star_border_outlined),
              checkedIcon: Icon(Icons.star_outlined),
            ),
            M3EToggleButtonGroupAction(
              label: Text(runtimeLabel),
              icon: const Icon(Icons.access_time_outlined),
              checkedIcon: const Icon(Icons.access_time_filled_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
