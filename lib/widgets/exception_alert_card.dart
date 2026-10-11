import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ExceptionSeverity {
  critical, // Red - Overdue, blocker, underperforming
  warning,  // Amber - Needs evaluation, proposal expiring
  action,   // Purple/Blue - CEO approval requested
}

/// A prioritized exception card designed to give the CEO immediate actionable visibility
/// into bottlenecks, overdue work, underperforming interns, and blocking issues.
class ExceptionAlertCard extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String? metaInfo;
  final ExceptionSeverity severity;
  final String actionLabel;
  final VoidCallback onAction;

  const ExceptionAlertCard({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    this.metaInfo,
    this.severity = ExceptionSeverity.critical,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color tagBgColor;
    Color tagTextColor;
    IconData icon;

    switch (severity) {
      case ExceptionSeverity.critical:
        borderColor = AppColors.statusOverdue.withOpacity(0.3);
        tagBgColor = AppColors.statusOverdueLight;
        tagTextColor = AppColors.statusOverdue;
        icon = Icons.error_outline_rounded;
        break;
      case ExceptionSeverity.warning:
        borderColor = AppColors.statusInProgress.withOpacity(0.35);
        tagBgColor = AppColors.statusInProgressLight;
        tagTextColor = AppColors.statusInProgress;
        icon = Icons.warning_amber_rounded;
        break;
      case ExceptionSeverity.action:
        borderColor = AppColors.electricBlue.withOpacity(0.3);
        tagBgColor = AppColors.electricBlueLight;
        tagTextColor = AppColors.electricBlue;
        icon = Icons.verified_user_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: tagTextColor),
                    const SizedBox(width: 4),
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: tagTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (metaInfo != null)
                Text(
                  metaInfo!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: severity == ExceptionSeverity.critical
                      ? AppColors.primaryDark
                      : AppColors.electricBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
