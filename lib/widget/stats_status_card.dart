import 'package:flutter/material.dart';

class StatsStatusCard extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String title;
  final int? movies;
  final int? runtime;
  final IconData icon;

  const StatsStatusCard({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.title,
    required this.movies,
    required this.runtime,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: Card(
        color: backgroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(
                    icon,
                    size: 16,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$movies',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$runtime Min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
