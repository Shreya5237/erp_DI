import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable clean status badge chip for tasks, intern decisions, leads, and project statuses.
class BadgeChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BadgeChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.fontSize = 11.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  factory BadgeChip.status(String status) {
    Color bg = AppColors.statusMutedLight;
    Color fg = AppColors.statusMuted;
    IconData? ic;

    switch (status.toLowerCase()) {
      case 'overdue':
      case 'reject':
      case 'lost':
      case 'delayed':
        bg = AppColors.statusOverdueLight;
        fg = AppColors.statusOverdue;
        ic = Icons.warning_amber_rounded;
        break;
      case 'approved':
      case 'retain':
      case 'retain / offer letter':
      case 'won':
      case 'completed':
      case 'active':
        bg = AppColors.statusCompletedLight;
        fg = AppColors.statusCompleted;
        ic = Icons.check_circle_outline_rounded;
        break;
      case 'in progress':
      case 'proposal':
      case 'proposal sent':
      case 'pending':
      case 'pending review':
        bg = AppColors.statusInProgressLight;
        fg = AppColors.statusInProgress;
        ic = Icons.schedule_rounded;
        break;
      case 'submitted':
      case 'in review':
      case 'qualified':
        bg = AppColors.statusReviewLight;
        fg = AppColors.statusReview;
        ic = Icons.assignment_turned_in_outlined;
        break;
      case 'to do':
      case 'new':
      case 'planning':
      case 'contacted':
        bg = AppColors.electricBlueLight;
        fg = AppColors.electricBlue;
        ic = Icons.fiber_manual_record;
        break;
      case 'needs rework':
        bg = AppColors.statusOverdueLight;
        fg = AppColors.statusOverdue;
        ic = Icons.refresh_rounded;
        break;
    }

    return BadgeChip(
      label: status,
      backgroundColor: bg,
      textColor: fg,
      icon: ic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
