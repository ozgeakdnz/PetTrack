import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/pt_gradient_button.dart';
import '../widgets/pt_header.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PtHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text(
              'Beslenme',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Luna için günlük kalori ve öğün planı.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GÜNLÜK HEDEF',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary.withValues(alpha: 0.95),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '840',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primary,
                                        height: 1,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'kcal / gün',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(height: 10, color: const Color(0xFFE8EAED)),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.72,
                                      child: Container(
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [AppColors.primary, AppColors.primaryLight],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '72%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: const [
                                Expanded(child: _Macro(label: 'Protein', value: '45g')),
                                Expanded(child: _Macro(label: 'Yağ', value: '18g')),
                                Expanded(child: _Macro(label: 'Lif', value: '12g')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2DFDB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Dengeli',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Bugünkü Öğünler',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Hepsini Gör',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          _MealCard(
            imageAsset: 'assets/images/meal_dry.png',
            topLine: 'SABAH • 08:30',
            title: 'ProPlan Adult Salmon',
            meta: '210 gr • Kuru Mama',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'TAMAMLANDI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
            ),
          ),
          _MealCard(
            imageAsset: 'assets/images/meal_wet.png',
            topLine: 'ÖĞLE • 13:00',
            title: 'Royal Canin Wet Food',
            meta: '150 gr • Konserve',
            accentLeft: true,
            trailing: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.primary,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'ONAYLA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ),
          ),
          _MealCard(
            imageAsset: 'assets/images/meal_evening.png',
            topLine: 'AKŞAM • 19:30',
            title: 'ProPlan Adult Salmon',
            meta: '210 gr • Kuru Mama',
            trailing: Icon(Icons.schedule_rounded, color: AppColors.textSecondary.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: PtGradientButton(
              label: 'Haftalık Planı Güncelle',
              icon: Icons.calendar_month_rounded,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB2DFDB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Beslenme Tavsiyesi',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Luna\'nın aktivite düzeyi bugün normalden yüksekti. Akşam öğününe ekstra 20gr protein eklemenizi öneririz.',
                          style: TextStyle(
                            height: 1.35,
                            color: AppColors.primary.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.imageAsset,
    required this.topLine,
    required this.title,
    required this.meta,
    required this.trailing,
    this.accentLeft = false,
  });

  final String imageAsset;
  final String topLine;
  final String title;
  final String meta;
  final Widget trailing;
  final bool accentLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            if (accentLeft)
              Container(
                width: 5,
                height: 92,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        imageAsset,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topLine,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary.withValues(alpha: 0.95),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meta,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
