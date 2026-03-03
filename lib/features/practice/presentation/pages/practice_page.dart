import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

class PracticePage extends StatelessWidget {
  const PracticePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Speed Limits', 'icon': Icons.speed, 'color': AppColors.primary, 'id': '1'},
      {'name': 'Road Signs', 'icon': Icons.traffic, 'color': AppColors.accent, 'id': '2'},
      {'name': 'Lane Control', 'icon': Icons.directions, 'color': AppColors.success, 'id': '3'},
      {'name': 'Parking Rules', 'icon': Icons.local_parking, 'color': AppColors.warning, 'id': '4'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practice Quiz'),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(
              context: context,
              name: category['name'] as String,
              icon: category['icon'] as IconData,
              color: category['color'] as Color,
              id: category['id'] as String,
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String name,
    required IconData icon,
    required Color color,
    required String id,
  }) {
    return GestureDetector(
      onTap: () => context.push('/practice/quiz/$id'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTextStyles.heading6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start →',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
