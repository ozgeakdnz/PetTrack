import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pet_models.dart';
import '../services/api_service.dart';
import '../state/active_pet_scope.dart';
import '../widgets/pet_switcher_bar.dart';
import '../theme/app_colors.dart';
import '../widgets/pt_action_sheets.dart';
import '../widgets/pt_gradient_button.dart';
import '../widgets/pt_header.dart';
import '../widgets/pt_screen_shell.dart';

class HealthDiaryScreen extends StatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  State<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends State<HealthDiaryScreen> {
  ActivePetScope? _scope;
  String? _loadedPetId;
  Pet? _pet;
  List<SymptomLog> _logs = [];
  bool _loading = true;
  bool _saving = false;

  String _symptomType = 'İştahsızlık';
  String _severity = 'LOW';
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<VaccinationEvent> _reminders = [];

  String get _dateLabel => DateFormat('dd/MM/yyyy').format(_selectedDate);

  static const _symptomOptions = [
    'Kusma',
    'İştahsızlık',
    'Halsizlik',
    'Öksürük',
    'Normal Durum',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scope?.removeListener(_onScopeChanged);
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ActivePetScopeWidget.of(context);
    if (!identical(_scope, next)) {
      _scope?.removeListener(_onScopeChanged);
      _scope = next;
      _scope!.addListener(_onScopeChanged);
      _load();
    }
  }

  void _onScopeChanged() {
    if (_scope!.activePetId != _loadedPetId) {
      _load();
    }
  }

  Future<void> _load() async {
    _pet = _scope?.activePet;
    _loadedPetId = _pet?.id;
    setState(() => _loading = true);
    try {
      _logs = await ApiService.instance.getSymptoms(petId: _pet?.id);
      if (_pet != null) {
        final month = DateFormat('yyyy-MM').format(DateTime.now());
        final cal = await ApiService.instance.getCalendar(month: month, petId: _pet!.id);
        _reminders = cal.reminders;
      }
    } catch (_) {
      _logs = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _export() async {
    try {
      final csv = await ApiService.instance.exportSymptoms(petId: _pet?.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Dışa Aktarma'),
          content: SingleChildScrollView(child: Text(csv.length > 500 ? '${csv.substring(0, 500)}...' : csv)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat')),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir evcil hayvan profili oluşturun')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ApiService.instance.createSymptom(
        petId: _pet!.id,
        symptom: _symptomType,
        severity: _severity,
        description: _descCtrl.text.trim(),
        createdAt: _selectedDate,
      );
      _descCtrl.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günlük kaydı eklendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _severityLabel(String s) {
    switch (s) {
      case 'HIGH':
        return 'Yüksek';
      case 'MEDIUM':
        return 'Orta';
      default:
        return 'Düşük';
    }
  }

  _Severity _mapSeverity(String s) {
    switch (s) {
      case 'HIGH':
        return _Severity.urgent;
      case 'MEDIUM':
        return _Severity.warning;
      default:
        return _Severity.ok;
    }
  }

  String _timeBadge(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Bugün, ${DateFormat.Hm('tr_TR').format(dt)}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return 'Dün, ${DateFormat.Hm('tr_TR').format(dt)}';
    }
    return DateFormat('d MMM, HH:mm', 'tr_TR').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return PtScreenShell(
      child: RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PtHeader(
              onNotificationsTap: () => showNotificationsSheet(context, _reminders),
            ),
            PetSwitcherBar(
              pets: _scope?.pets ?? [],
              activePetId: _scope?.activePetId,
              onSelected: (id) => _scope!.selectPet(id),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Text(
                'Sağlık Günlüğü',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pati dostunuzun günlük sağlık değişimlerini buradan takip edebilirsiniz.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.35),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _export,
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('CSV'),
                  ),
                ],
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
                        key: ValueKey(_dateLabel),
                        readOnly: true,
                        onTap: _pickDate,
                        initialValue: _dateLabel,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary.withValues(alpha: 0.95)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Labeled(
                      'Semptom Türü',
                      DropdownButtonFormField<String>(
                        value: _symptomType,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary.withValues(alpha: 0.95)),
                        ),
                        items: _symptomOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _symptomType = v ?? _symptomType),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Labeled(
                      'Şiddet Seviyesi',
                      Row(
                        children: [
                          Expanded(
                            child: _SeverityChip(
                              label: 'Düşük',
                              selected: _severity == 'LOW',
                              border: const Color(0xFFA7F3D0),
                              background: const Color(0xFFD1FAE5),
                              foreground: const Color(0xFF047857),
                              onTap: () => setState(() => _severity = 'LOW'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SeverityChip(
                              label: 'Orta',
                              selected: _severity == 'MEDIUM',
                              border: const Color(0xFFFDE68A),
                              background: const Color(0xFFFFFBEB),
                              foreground: const Color(0xFFB45309),
                              onTap: () => setState(() => _severity = 'MEDIUM'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SeverityChip(
                              label: 'Yüksek',
                              selected: _severity == 'HIGH',
                              border: const Color(0xFFFECACA),
                              background: const Color(0xFFFEF2F2),
                              foreground: const Color(0xFFB91C1C),
                              onTap: () => setState(() => _severity = 'HIGH'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Labeled(
                      'Açıklama',
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: 'Belirtileri buraya yazın...'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PtGradientButton(
                      label: _saving ? 'Kaydediliyor...' : 'Günlüğü Kaydet',
                      onPressed: _saving ? null : _save,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Geçmiş Kayıtlar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_logs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Henüz kayıt yok.', style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              ..._logs.map(
                (log) => _TimelineEntry(
                  severity: _mapSeverity(log.severity),
                  title: log.symptom,
                  severityLabel: _severityLabel(log.severity),
                  timeBadge: _timeBadge(log.createdAt.toLocal()),
                  body: log.description ?? '—',
                ),
              ),
          ],
        ),
      ),
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

enum _Severity { urgent, warning, ok }

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.label,
    required this.selected,
    required this.border,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color border;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? background : AppColors.cardWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? border : AppColors.borderSoft, width: selected ? 1.5 : 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? foreground : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.severity,
    required this.title,
    required this.severityLabel,
    required this.timeBadge,
    required this.body,
  });

  final _Severity severity;
  final String title;
  final String severityLabel;
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
                      decoration: BoxDecoration(color: bar, borderRadius: BorderRadius.circular(4)),
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
                                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2F4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  severityLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w700,
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
