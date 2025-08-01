import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';

class TimelineSection extends StatelessWidget {
  final List<JobApplication> applications;

  const TimelineSection({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyApplicationData(applications);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Application Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: TimelineChartPainter(monthlyData),
              size: const Size(double.infinity, 160),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: monthlyData.entries.map((entry) {
              return Column(
                children: [
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getMonthlyApplicationData(
    List<JobApplication> applications,
  ) {
    final now = DateTime.now();
    final months = <String, int>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.month}/${month.year}';
      months[monthKey] = 0;
    }

    for (final app in applications) {
      final month = DateTime(app.appliedAt.year, app.appliedAt.month, 1);
      final monthKey = '${month.month}/${month.year}';
      if (months.containsKey(monthKey)) {
        months[monthKey] = (months[monthKey] ?? 0) + 1;
      }
    }

    return months;
  }
}

class TimelineChartPainter extends CustomPainter {
  final Map<String, int> monthlyData;

  TimelineChartPainter(this.monthlyData);

  @override
  void paint(Canvas canvas, Size size) {
    if (monthlyData.isEmpty) return;

    final values = monthlyData.values.toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) return;

    final width = size.width;
    final height = size.height;
    final barWidth = width / values.length;
    final padding = barWidth * 0.3;

    for (int i = 0; i < values.length; i++) {
      final normalizedHeight = (values[i] / maxValue) * (height - 40);
      final x = i * barWidth + padding;
      final y = height - normalizedHeight - 20;

      // Draw bar with gradient
      final barRect = Rect.fromLTWH(
        x,
        y,
        barWidth - padding * 2,
        normalizedHeight,
      );
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary, const Color(0xFF667EEA)],
      ).createShader(barRect);

      final barPaint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(8)),
        barPaint,
      );

      // Draw value on top
      final textPainter = TextPainter(
        text: TextSpan(
          text: values[i].toString(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - padding * 2) / 2 - textPainter.width / 2,
          y - 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
