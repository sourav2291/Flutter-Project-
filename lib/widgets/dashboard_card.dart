// widgets/dashboard_card.dart

import 'package:flutter/material.dart';

import 'glass_card.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      blur: 14,
      opacity: 0.16,
      padding: const EdgeInsets.all(15),

      child: InkWell(
        borderRadius: BorderRadius.circular(22),

        onTap: onTap,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // ICON + ARROW
            // ==================================================
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,

                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),

                    borderRadius: BorderRadius.circular(15),

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),

                  child: Icon(icon, color: color, size: 26),
                ),

                const Spacer(),

                Container(
                  width: 28,
                  height: 28,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),

                    shape: BoxShape.circle,

                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),

                  child: Icon(
                    Icons.arrow_forward_ios_rounded,

                    size: 13,

                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ==================================================
            // COUNT
            // ==================================================
            Text(
              count,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 29,

                fontWeight: FontWeight.w800,

                color: Colors.white,

                height: 1.0,
              ),
            ),

            const SizedBox(height: 7),

            // ==================================================
            // TITLE
            // ==================================================
            Text(
              title,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 14,

                color: Colors.white.withValues(alpha: 0.78),

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
