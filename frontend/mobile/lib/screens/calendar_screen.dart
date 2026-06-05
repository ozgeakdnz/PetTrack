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

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  ActivePetScope? _scope;
  String? _loadedPetId;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selected = DateTime.now();
  Pet? _pet;
  List<VaccinationEvent> _events = [];
  List<VaccinationEvent> _reminders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scope?.removeListener(_onScopeChanged);
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

  String get _monthKey =>
      '${_month.year}-${_month.month.toString().padLeft(2, '0')}';

  Set<int> get _eventDays => _events.map((e) => e.date.toLocal().day).toSet();

  Future<void> _load() async {
    _pet = _scope?.activePet;
    _loadedPetId = _pet?.id;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_pet != null) {
        final data = await ApiService.instance.getCalendar(month: _monthKey, petId: _pet!.id);
        _events = data.events;
        _reminders = data.reminders;
      } else {
        _events = [];
        _reminders = [];
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _events = [];
      _reminders = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addReminder() async {
    if (_pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir evcil hayvan profili oluşturun')),
      );
      return;
    }
    final ok = await showAddCalendarSheet(context, petId: _pet!.id);
    if (ok == true) await _load();
  }

  Future<void> _toggleReminder(VaccinationEvent event) async {
    final next = event.isCompleted ? 'PENDING' : 'COMPLETED';
    try {
      await ApiService.instance.updateCalendarEvent(event.id, status: next);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next == 'COMPLETED' ? 'Tamamlandı olarak işaretlendi' : 'Yaklaşan olarak işaretlendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _prevMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month - 1);
    });
    _load();
  }

  void _nextMonth() {
    setState(() {
      _month = DateTime(_month.year, _month.month + 1);
    });
    _load();
  }

  void _showAllReminders() {
    showAllItemsSheet(
      context,
      title: 'Tüm Hatırlatıcılar',
      children: _reminders.isEmpty
          ? [Padding(padding: EdgeInsets.all(20), child: Text('Kayıt yok.', style: TextStyle(color: AppColors.textSecondary)))]
          : _reminders
              .map(
                (r) => _ReminderCard(
                  accent: r.isCompleted ? AppColors.textSecondary : AppColors.primary,
                  icon: Icons.vaccines_rounded,
                  title: r.name,
                  subtitle: '${r.petName ?? _pet?.name ?? ''}${r.notes != null && r.notes!.isNotEmpty ? ' • ${r.notes}' : ''}',
                  metaLines: [
                    _MetaLine(Icons.calendar_today_rounded, DateFormat('d MMMM, HH:mm', 'tr_TR').format(r.date.toLocal())),
                  ],
                  badge: r.isCompleted ? _Badge.completed() : _Badge.upcoming(),
                  muted: r.isCompleted,
                  onTap: () => _toggleReminder(r),
                ),
              )
              .toList(),
    );
  }

  List<VaccinationEvent> get _selectedDayEvents => _events.where((e) {
        final d = e.date.toLocal();
        return d.year == _selected.year && d.month == _selected.month && d.day == _selected.day;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final title = DateFormat.yMMMM('tr_TR').format(_month);

    return PtScreenShell(
      child: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PtHeader(onNotificationsTap: () => showNotificationsSheet(context, _reminders)),
              PetSwitcherBar(
                pets: _scope?.pets ?? [],
                activePetId: _scope?.activePetId,
                onSelected: (id) => _scope!.selectPet(id),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Text(
                  'Aşı Takvimi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  _pet != null
                      ? '${_pet!.name} için sağlık yolculuğunu takip edin.'
                      : 'Pati dostunuzun sağlık yolculuğunu takip edin.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(_error!, style: const TextStyle(color: AppColors.urgent, fontSize: 13)),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded)),
                                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _MonthGrid(
                              month: _month,
                              selected: _selected,
                              eventDays: _eventDays,
                              onSelect: (d) => setState(() => _selected = d),
                            ),
                          ],
                        ),
                ),
              ),
              if (_selectedDayEvents.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    DateFormat('d MMMM', 'tr_TR').format(_selected),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
                ..._selectedDayEvents.map(
                  (e) => _ReminderCard(
                    accent: e.isCompleted ? AppColors.textSecondary : AppColors.primary,
                    icon: Icons.event_rounded,
                    title: e.name,
                    subtitle: e.notes ?? (e.petName ?? ''),
                    metaLines: [
                      _MetaLine(Icons.access_time_rounded, DateFormat.Hm('tr_TR').format(e.date.toLocal())),
                    ],
                    badge: e.isCompleted ? _Badge.completed() : _Badge.upcoming(),
                    muted: e.isCompleted,
                    onTap: () => _toggleReminder(e),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Yaklaşan Hatırlatıcılar',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _showAllReminders,
                      child: const Text(
                        'Tümünü Gör',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_reminders.isEmpty && !_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Henüz hatırlatıcı yok.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                ..._reminders.take(3).map(
                      (r) => _ReminderCard(
                        accent: r.isCompleted ? AppColors.textSecondary : AppColors.primary,
                        icon: Icons.vaccines_rounded,
                        title: r.name,
                        subtitle: '${r.petName ?? _pet?.name ?? ''}${r.notes != null && r.notes!.isNotEmpty ? ' • ${r.notes}' : ''}',
                        metaLines: [
                          _MetaLine(Icons.calendar_today_rounded, DateFormat('d MMMM, HH:mm', 'tr_TR').format(r.date.toLocal())),
                        ],
                        badge: r.isCompleted ? _Badge.completed() : _Badge.upcoming(),
                        muted: r.isCompleted,
                        onTap: () => _toggleReminder(r),
                      ),
                    ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PtGradientButton(
                  label: 'Hatırlatıcı Ekle',
                  icon: Icons.add_rounded,
                  onPressed: _addReminder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.eventDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selected;
  final Set<int> eventDays;
  final ValueChanged<DateTime> onSelect;

  static const _weekdays = ['PT', 'SA', 'ÇAR', 'PER', 'CU', 'CT', 'PZ'];

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final nextMonth = DateTime(month.year, month.month + 1);
    final daysInMonth = nextMonth.difference(first).inDays;

    // Pazartesi ilk sütun (PT, SA, ÇAR…).
    const startWeekdayMonday = 1;
    final leadingBlanks = (first.weekday - startWeekdayMonday + 7) % 7;

    final prevDays = DateTime(month.year, month.month, 0).day;

    final cells = <_DayCell>[];

    for (var i = 0; i < leadingBlanks; i++) {
      final dayNum = prevDays - leadingBlanks + i + 1;
      cells.add(_DayCell(
        label: '$dayNum',
        muted: true,
        onTap: () {},
      ));
    }

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final isSel = date.year == selected.year && date.month == selected.month && date.day == selected.day;
      cells.add(_DayCell(
        label: '$d',
        selected: isSel,
        dot: eventDays.contains(d),
        onTap: () => onSelect(date),
      ));
    }

    var nextDay = 1;
    while (cells.length % 7 != 0) {
      cells.add(_DayCell(label: '$nextDay', muted: true, onTap: () {}));
      nextDay++;
    }
    while (cells.length < 42) {
      cells.add(_DayCell(label: '$nextDay', muted: true, onTap: () {}));
      nextDay++;
    }

    return Column(
      children: [
        Row(
          children: _weekdays
              .map(
                (w) => Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 44,
          ),
          itemBuilder: (_, i) => cells[i],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.dot = false,
    this.muted = false,
  });

  final String label;
  final bool selected;
  final bool dot;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Colors.white
        : muted
            ? AppColors.textSecondary.withValues(alpha: 0.45)
            : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: fg,
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (dot && !muted)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }
}

class _MetaLine {
  const _MetaLine(this.icon, this.text);
  final IconData icon;
  final String text;
}

class _Badge {
  const _Badge._(this.label, this.bg, this.fg);

  final String label;
  final Color bg;
  final Color fg;

  factory _Badge.upcoming() => const _Badge._(
        'YAKLAŞAN',
        Color(0xFFB2DFDB),
        AppColors.primary,
      );

  factory _Badge.completed() => const _Badge._(
        'TAMAMLANDI',
        Color(0xFFE8EAED),
        AppColors.textSecondary,
      );
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metaLines,
    required this.badge,
    this.muted = false,
    this.onTap,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_MetaLine> metaLines;
  final _Badge badge;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Opacity(
        opacity: muted ? 0.72 : 1,
        child: Material(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                constraints: const BoxConstraints(minHeight: 108),
                decoration: BoxDecoration(
                  color: muted ? AppColors.borderSoft : accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: muted ? const Color(0xFFEEF0F2) : const Color(0xFFB2DFDB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: muted ? AppColors.textSecondary : AppColors.primary),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: badge.bg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    badge.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: badge.fg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            if (metaLines.isNotEmpty) const SizedBox(height: 10),
                            ...metaLines.map(
                              (m) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(m.icon, size: 15, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        m.text,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary.withValues(alpha: 0.95),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
            ),
          ),
        ),
      ),
    );
  }
}
