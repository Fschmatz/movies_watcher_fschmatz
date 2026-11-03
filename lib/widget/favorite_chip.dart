import 'package:flutter/material.dart';

import '../util/app_constants.dart';

class FavoriteChip extends StatelessWidget {
  final int gridSize;

  const FavoriteChip({super.key, this.gridSize = 3});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 6,
      left: 6,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiaryContainer.withAlpha(230),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.star,
          size: AppConstants.mapFavoriteChipIconSize[gridSize] ?? 14,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
