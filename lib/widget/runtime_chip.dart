import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/util/utils_functions.dart';

class RuntimeChip extends StatelessWidget {
  final int runtime;
  final bool showMovieName;
  final bool formatRuntime;
  final int gridSize;

  const RuntimeChip({
    super.key,
    required this.runtime,
    required this.showMovieName,
    this.formatRuntime = false,
    this.gridSize = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: UtilsFunctions.getRuntimeChipBottom(gridSize, showMovieName),
      right: UtilsFunctions.getRuntimeChipRight(gridSize, showMovieName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withAlpha(230),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          UtilsFunctions.formatRuntime(runtime, formatRuntime),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
