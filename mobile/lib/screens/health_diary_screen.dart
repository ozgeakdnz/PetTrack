import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/pt_gradient_button.dart';
import '../widgets/pt_header.dart';

class HealthDiaryScreen extends StatelessWidget {
  const HealthDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PtHeader(showProfileAvatar: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text(
              'Sağlık Günlüğü',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Pati dostunuzun günlük sağlık değişimlerini buradan takip edebilirsiniz.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.35),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1F3),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Labeled(
                    'Tarih Seçin',
                    TextFormField(
                      initialValue: '10/24/2023',
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary.withValues(alpha: 0.95)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Labeled(
                    'Semptom Türü',
                    TextFormField(
                      initialValue: 'İştahsızlık',
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary.withValues(alpha: 0.95)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Labeled(
                    'Açıklama',
                    TextFormField(
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Belirtileri buraya yazın...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PtGradientButton(
                    label: 'Günlüğü Kaydet',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Geçmiş Kayıtlar',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
          const SizedBox(height: 14),
          _TimelineEntry(
            severity: _Severity.urgent,
            title: 'Ciddi Kusma',
            timeBadge: 'Bugün, 09:15',
            body:
                'Sabah saatlerinde 3 kez kusma ve halsizlik gözlemlendi. Veteriner ile iletişime geçildi.',
          ),
          _TimelineEntry(
            severity: _Severity.warning,
            title: 'İştahsızlık',
            timeBadge: 'Dün, 18:30',
            body: 'Mamasını yavaş yedi ve kabın yarısını bıraktı.',
          ),
          _TimelineEntry(
            severity: _Severity.ok,
            title: 'Normal Durum',
            timeBadge: '22 Eki, 10:00',
            body: 'Tüm değerler normal, enerji yüksek.',
          ),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

enum _Severity { urgent, warning, ok }

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.severity,
    required this.title,
    required this.timeBadge,
    required this.body,
  });

  final _Severity severity;
  final String title;
  final String timeBadge;
  final String body;

  @override
  Widget build(BuildContext context) {
    late Color bar;
    late Color iconBg;
    late Widget icon;

    switch (severity) {
      case _Severity.urgent:
        bar = AppColors.urgent;
        iconBg = AppColors.urgent;
        icon = const Icon(Icons.priority_high_rounded, color: Colors.white, size: 18);
        break;
      case _Severity.warning:
        bar = AppColors.warningDark;
        iconBg = AppColors.warning;
        icon = Icon(Icons.warning_amber_rounded, color: AppColors.warningDark.withValues(alpha: 0.95), size: 18);
        break;
      case _Severity.ok:
        bar = AppColors.primary;
        iconBg = AppColors.timelineOk;
        icon = const Icon(Icons.check_rounded, color: AppColors.primary, size: 18);
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 14),
                      color: const Color(0xFFE0E3E6),
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: icon,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSoft.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: bar,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2F4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  timeBadge,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            body,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: AppColors.textSecondary.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
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
