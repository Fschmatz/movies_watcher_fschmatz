import 'package:flutter/material.dart';

class MovieDetailTile extends StatelessWidget {
  final String title;
  final String? value;

  const MovieDetailTile({
    super.key,
    required this.title,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color onSecondary = theme.colorScheme.onSecondaryContainer;
    TextStyle titleStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSecondary);
    const TextStyle subtitleStyle = TextStyle(fontSize: 14);

    return ListTile(
      title: Text(
        title,
        style: titleStyle,
      ),
      subtitle: Text(
        (value == null || value!.isEmpty) ? "-" : value!,
        style: subtitleStyle,
      ),
      dense: true,
    );
  }
}
