import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';

class BenefitsSection extends StatelessWidget {
  final JobOpening job;

  const BenefitsSection({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BenefitsHeader(),
        const SizedBox(height: 16),
        _BenefitsGrid(benefitItems: _createBenefitItems()),
      ],
    );
  }

  List<Map<String, dynamic>> _createBenefitItems() {
    List<Map<String, dynamic>> benefitItems = [];

    // Add salary if available
    if (job.salaryRange != null) {
      benefitItems.add({
        'icon': Icons.attach_money,
        'title': job.salaryRange,
        'color': AppColors.success,
      });
    }

    // Add job type
    benefitItems.add({
      'icon': Icons.work_outline,
      'title': '${job.jobType.replaceAll('-', ' ').toUpperCase()} Job',
      'color': AppColors.primary,
    });

    // Add experience level
    benefitItems.add({
      'icon': Icons.trending_up,
      'title': '${job.experienceLevel.toUpperCase()} Level',
      'color': AppColors.brandPurple,
    });

    // Add benefits from job data
    for (String benefit in job.benefits) {
      final benefitData = BenefitMapper.mapBenefit(benefit);
      benefitItems.add(benefitData);
    }

    return benefitItems;
  }
}

class _BenefitsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.card_giftcard,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Benefits & Perks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BenefitsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> benefitItems;

  const _BenefitsGrid({required this.benefitItems});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 3.0,
      ),
      itemCount: benefitItems.length,
      itemBuilder: (context, index) {
        final benefit = benefitItems[index];
        return _BenefitCard(benefit: benefit);
      },
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final Map<String, dynamic> benefit;

  const _BenefitCard({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: benefit['color'].withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _BenefitIcon(icon: benefit['icon'], color: benefit['color']),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit['title'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _BenefitIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class BenefitMapper {
  static Map<String, dynamic> mapBenefit(String benefit) {
    IconData icon;
    Color color;

    // Health & Wellness Benefits
    if (benefit.toLowerCase().contains('health') ||
        benefit.toLowerCase().contains('medical') ||
        benefit.toLowerCase().contains('dental') ||
        benefit.toLowerCase().contains('vision') ||
        benefit.toLowerCase().contains('insurance')) {
      icon = Icons.local_hospital_outlined;
      color = AppColors.error;
    }
    // Time Off Benefits
    else if (benefit.toLowerCase().contains('time off') ||
        benefit.toLowerCase().contains('vacation') ||
        benefit.toLowerCase().contains('holiday') ||
        benefit.toLowerCase().contains('sick') ||
        benefit.toLowerCase().contains('leave') ||
        benefit.toLowerCase().contains('pto')) {
      icon = Icons.schedule_outlined;
      color = AppColors.warning;
    }
    // Remote Work Benefits
    else if (benefit.toLowerCase().contains('remote') ||
        benefit.toLowerCase().contains('work from home') ||
        benefit.toLowerCase().contains('hybrid') ||
        benefit.toLowerCase().contains('flexible location')) {
      icon = Icons.home_work_outlined;
      color = AppColors.brandGreen;
    }
    // Food & Meal Benefits
    else if (benefit.toLowerCase().contains('food') ||
        benefit.toLowerCase().contains('meal') ||
        benefit.toLowerCase().contains('lunch') ||
        benefit.toLowerCase().contains('breakfast') ||
        benefit.toLowerCase().contains('dinner') ||
        benefit.toLowerCase().contains('snacks') ||
        benefit.toLowerCase().contains('catering')) {
      icon = Icons.restaurant_outlined;
      color = AppColors.warning;
    }
    // Financial Benefits
    else if (benefit.toLowerCase().contains('bonus') ||
        benefit.toLowerCase().contains('commission') ||
        benefit.toLowerCase().contains('profit sharing') ||
        benefit.toLowerCase().contains('stock') ||
        benefit.toLowerCase().contains('equity') ||
        benefit.toLowerCase().contains('401k') ||
        benefit.toLowerCase().contains('retirement') ||
        benefit.toLowerCase().contains('pension')) {
      icon = Icons.monetization_on_outlined;
      color = AppColors.success;
    }
    // Transportation Benefits
    else if (benefit.toLowerCase().contains('transport') ||
        benefit.toLowerCase().contains('parking') ||
        benefit.toLowerCase().contains('commute') ||
        benefit.toLowerCase().contains('uber') ||
        benefit.toLowerCase().contains('lyft') ||
        benefit.toLowerCase().contains('gas') ||
        benefit.toLowerCase().contains('mileage')) {
      icon = Icons.directions_car_outlined;
      color = AppColors.info;
    }
    // Education & Training Benefits
    else if (benefit.toLowerCase().contains('education') ||
        benefit.toLowerCase().contains('training') ||
        benefit.toLowerCase().contains('learning') ||
        benefit.toLowerCase().contains('course') ||
        benefit.toLowerCase().contains('certification') ||
        benefit.toLowerCase().contains('degree') ||
        benefit.toLowerCase().contains('tuition')) {
      icon = Icons.school_outlined;
      color = AppColors.brandPurple;
    }
    // Technology Benefits
    else if (benefit.toLowerCase().contains('laptop') ||
        benefit.toLowerCase().contains('computer') ||
        benefit.toLowerCase().contains('phone') ||
        benefit.toLowerCase().contains('equipment') ||
        benefit.toLowerCase().contains('software') ||
        benefit.toLowerCase().contains('tech') ||
        benefit.toLowerCase().contains('gadget')) {
      icon = Icons.laptop_outlined;
      color = AppColors.info;
    }
    // Gym & Fitness Benefits
    else if (benefit.toLowerCase().contains('gym') ||
        benefit.toLowerCase().contains('fitness') ||
        benefit.toLowerCase().contains('workout') ||
        benefit.toLowerCase().contains('exercise') ||
        benefit.toLowerCase().contains('wellness') ||
        benefit.toLowerCase().contains('yoga') ||
        benefit.toLowerCase().contains('sports')) {
      icon = Icons.fitness_center_outlined;
      color = AppColors.error;
    }
    // Childcare Benefits
    else if (benefit.toLowerCase().contains('childcare') ||
        benefit.toLowerCase().contains('daycare') ||
        benefit.toLowerCase().contains('family') ||
        benefit.toLowerCase().contains('parental') ||
        benefit.toLowerCase().contains('maternity') ||
        benefit.toLowerCase().contains('paternity')) {
      icon = Icons.family_restroom_outlined;
      color = AppColors.brandPurple;
    }
    // Professional Development
    else if (benefit.toLowerCase().contains('conference') ||
        benefit.toLowerCase().contains('workshop') ||
        benefit.toLowerCase().contains('seminar') ||
        benefit.toLowerCase().contains('networking') ||
        benefit.toLowerCase().contains('mentorship') ||
        benefit.toLowerCase().contains('career growth')) {
      icon = Icons.trending_up_outlined;
      color = AppColors.primary;
    }
    // Entertainment Benefits
    else if (benefit.toLowerCase().contains('entertainment') ||
        benefit.toLowerCase().contains('movie') ||
        benefit.toLowerCase().contains('game') ||
        benefit.toLowerCase().contains('recreation') ||
        benefit.toLowerCase().contains('fun') ||
        benefit.toLowerCase().contains('leisure')) {
      icon = Icons.movie_outlined;
      color = AppColors.warning;
    }
    // Office Perks
    else if (benefit.toLowerCase().contains('coffee') ||
        benefit.toLowerCase().contains('drinks') ||
        benefit.toLowerCase().contains('beverages') ||
        benefit.toLowerCase().contains('office') ||
        benefit.toLowerCase().contains('workspace') ||
        benefit.toLowerCase().contains('environment')) {
      icon = Icons.local_cafe_outlined;
      color = AppColors.warning;
    }
    // Pet Benefits
    else if (benefit.toLowerCase().contains('pet') ||
        benefit.toLowerCase().contains('dog') ||
        benefit.toLowerCase().contains('cat') ||
        benefit.toLowerCase().contains('animal')) {
      icon = Icons.pets_outlined;
      color = AppColors.brandGreen;
    }
    // Legal Benefits
    else if (benefit.toLowerCase().contains('legal') ||
        benefit.toLowerCase().contains('lawyer') ||
        benefit.toLowerCase().contains('attorney') ||
        benefit.toLowerCase().contains('legal aid')) {
      icon = Icons.gavel_outlined;
      color = AppColors.info;
    }
    // Mental Health Benefits
    else if (benefit.toLowerCase().contains('mental health') ||
        benefit.toLowerCase().contains('therapy') ||
        benefit.toLowerCase().contains('counseling') ||
        benefit.toLowerCase().contains('psychology') ||
        benefit.toLowerCase().contains('wellness program')) {
      icon = Icons.psychology_outlined;
      color = AppColors.brandPurple;
    }
    // Flexible Schedule
    else if (benefit.toLowerCase().contains('flexible') ||
        benefit.toLowerCase().contains('flex time') ||
        benefit.toLowerCase().contains('flexible hours') ||
        benefit.toLowerCase().contains('work life balance')) {
      icon = Icons.access_time_outlined;
      color = AppColors.primary;
    }
    // Dress Code Benefits
    else if (benefit.toLowerCase().contains('casual') ||
        benefit.toLowerCase().contains('dress') ||
        benefit.toLowerCase().contains('attire') ||
        benefit.toLowerCase().contains('jeans')) {
      icon = Icons.checkroom_outlined;
      color = AppColors.info;
    }
    // Default for any other benefits
    else {
      icon = Icons.star_outline;
      color = AppColors.info;
    }

    return {'icon': icon, 'title': benefit, 'color': color};
  }
}
