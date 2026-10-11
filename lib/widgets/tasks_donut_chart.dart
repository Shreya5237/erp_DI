import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Donut chart for Tasks Overview matching Screen 2
class TasksDonutChart extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int todo;
  final int overdue;
  final int needsRework;

  const TasksDonutChart({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.todo,
    required this.overdue,
    required this.needsRework,
  });

  @override
  Widget build(BuildContext context) {
    final total = completed + inProgress + todo + overdue + needsRework;

    return Row(
      children: [
        // Donut Chart on left
        SizedBox(
          width: 110,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(110, 110),
                painter: _DonutChartPainter(
                  slices: [
                    _Slice(completed, const Color(0xFF1E293B)), // Dark slate
                    _Slice(inProgress, const Color(0xFF64748B)), // Slate
                    _Slice(todo, const Color(0xFF94A3B8)), // Muted slate
                    _Slice(overdue, const Color(0xFF0F172A)), // Black
                    _Slice(needsRework, const Color(0xFFCBD5E1)), // Light slate
                  ],
                  total: total > 0 ? total : 1,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Total Tasks',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Legend on right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendRow('Completed', completed, const Color(0xFF1E293B)),
              const SizedBox(height: 5),
              _buildLegendRow('In Progress', inProgress, const Color(0xFF64748B)),
              const SizedBox(height: 5),
              _buildLegendRow('To Do', todo, const Color(0xFF94A3B8)),
              const SizedBox(height: 5),
              _buildLegendRow('Overdue', overdue, const Color(0xFF0F172A)),
              const SizedBox(height: 5),
              _buildLegendRow('Needs Rework', needsRework, const Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _Slice {
  final int count;
  final Color color;
  _Slice(this.count, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_Slice> slices;
  final int total;

  _DonutChartPainter({required this.slices, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.count <= 0) continue;
      final sweepAngle = (slice.count / total) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total;
  }
}
