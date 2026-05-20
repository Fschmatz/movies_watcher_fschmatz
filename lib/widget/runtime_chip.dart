import 'package:flutter/material.dart';

class RuntimeChip extends StatelessWidget {
  final int runtime;
  final bool showMovieName;

  const RuntimeChip({
    super.key,
    required this.runtime,
    required this.showMovieName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: showMovieName ? 4 : 8,
      right: showMovieName ? 4 : 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 12,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              "$runtime",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
