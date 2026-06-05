import 'package:flutter/material.dart';

import '../models/pet_models.dart';
import '../services/api_service.dart';
import '../state/active_pet_scope.dart';
import '../widgets/pet_switcher_bar.dart';
import '../theme/app_colors.dart';
import '../widgets/pt_action_sheets.dart';
import '../widgets/pt_gradient_button.dart';
import '../widgets/pt_header.dart';
import '../widgets/pt_screen_shell.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  ActivePetScope? _scope;
  String? _loadedPetId;
  Pet? _pet;
  NutritionSummary? _summary;
  List<NutritionItem> _meals = [];
  bool _loading = true;
  String? _error;

  String _focus = 'Kilo Koruma';
  int _mealCount = 3;

  static const _focusOptions = ['Kilo Koruma', 'Kilo Verme', 'Kilo Alma'];

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

  Future<void> _load() async {
    _pet = _scope?.activePet;
    _loadedPetId = _pet?.id;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_pet != null) {
        final results = await Future.wait([
          ApiService.instance.getNutritionSummary(_pet!.id),
          ApiService.instance.getNutrition(petId: _pet!.id),
        ]);
        _summary = results[0] as NutritionSummary;
        _meals = results[1] as List<NutritionItem>;
      } else {
        _summary = null;
        _meals = [];
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _summary = null;
      _meals = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmMeal(NutritionItem meal) async {
    try {
      await ApiService.instance.updateNutrition(meal.id, {'status': 'COMPLETED'});
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Öğün onaylandı')),
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

  Future<void> _addMeal() async {
    if (_pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir evcil hayvan profili oluşturun')),
      );
      return;
    }
    final ok = await showAddNutritionSheet(
      context,
      petId: _pet!.id,
      frequency: _mealCount,
      dietFocus: _focus,
    );
    if (ok == true) await _load();
  }

  int _baseKcal(Pet? pet) {
    if (pet?.weight != null) {
      return (30 * pet!.weight! + 70).round();
    }
    return 1240;
  }

  double _focusMultiplier(String focus) {
    switch (focus) {
      case 'Kilo Verme':
        return 0.9;
      case 'Kilo Alma':
        return 1.1;
      default:
        return 1.0;
    }
  }

  double _mealMultiplier(int count) {
    if (count == 2) return 0.95;
    if (count == 4) return 1.05;
    return 1.0;
  }

  int _planDailyTarget(Pet? pet) {
    final target = (_baseKcal(pet) * _focusMultiplier(_focus) * _mealMultiplier(_mealCount)).round();
    return target < 300 ? 300 : target;
  }

  String _planTip() {
    switch (_focus) {
      case 'Kilo Verme':
        return 'Evcil hayvanın kilo kontrolü için öğünler düzenli saatlerde verilmeli, günlük hareket süresi artırılmalı ve öğün sayısı $_mealCount olarak korunmalıdır.';
      case 'Kilo Alma':
        return 'Evcil hayvanın kilo alımını desteklemek için enerji yoğunluğu daha yüksek öğünler tercih edilmeli, protein oranı artırılmalı ve öğün sayısı $_mealCount olarak planlanmalıdır.';
      default:
        return 'Evcil hayvanın kilosu dengede tutmak için mevcut öğün planına sadık kalınmalı, su tüketimi takip edilmeli ve günlük aktivite seviyesi düzenli sürdürülmelidir.';
    }
  }

  Future<void> _applyPlan() async {
    if (_pet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir evcil hayvan profili oluşturun')),
      );
      return;
    }
    setState(() {});
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan güncellendi')),
      );
    }
  }

  void _showAllMeals() {
    showAllItemsSheet(
      context,
      title: 'Tüm Öğünler',
      children: _meals.isEmpty
          ? [Padding(padding: EdgeInsets.all(20), child: Text('Öğün yok.', style: TextStyle(color: AppColors.textSecondary)))]
          : _meals.map((m) => _buildMealCard(m)).toList(),
    );
  }

  String _mealPeriod(String feedTime) {
    final parts = feedTime.split(':');
    if (parts.isEmpty) return 'ÖĞÜN';
    final hour = int.tryParse(parts[0]) ?? 12;
    if (hour < 11) return 'SABAH';
    if (hour < 16) return 'ÖĞLE';
    return 'AKŞAM';
  }

  Widget _buildMealCard(NutritionItem meal) {
    final completed = meal.isCompleted;
    final typeLabel = _mealTypeLabel(meal);
    return _MealCard(
      imageAsset: _mealImageFor(meal),
      topLine: '${_mealPeriod(meal.feedTime)} • ${meal.feedTime}',
      title: meal.foodName,
      meta: '${meal.amount} • $typeLabel${meal.notes != null && meal.notes!.isNotEmpty && !_focusOptions.contains(meal.notes) ? ' • ${meal.notes}' : ''}',
      accentLeft: !completed,
      trailing: completed
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'TAMAMLANDI',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
              ),
            )
          : Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => _confirmMeal(meal),
                borderRadius: BorderRadius.circular(18),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    'ONAYLA',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ),
            ),
    );
  }

  String _mealTypeLabel(NutritionItem meal) {
    final lower = meal.foodName.toLowerCase();
    if (lower.contains('wet') || lower.contains('konserve') || lower.contains('yaş')) {
      return 'Yaş Mama';
    }
    if (_mealPeriod(meal.feedTime) == 'ÖĞLE') return 'Yaş Mama';
    return 'Kuru Mama';
  }

  String _mealImageFor(NutritionItem meal) {
    final lower = meal.foodName.toLowerCase();
    if (lower.contains('wet') || lower.contains('konserve') || lower.contains('yaş')) {
      return 'assets/images/meal_wet.png';
    }
    switch (_mealPeriod(meal.feedTime)) {
      case 'ÖĞLE':
        return 'assets/images/meal_wet.png';
      case 'AKŞAM':
        return 'assets/images/meal_evening.png';
      default:
        return 'assets/images/meal_dry.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final petName = summary?.petName ?? _pet?.name ?? 'Pati Dostu';
    final dailyTarget = _planDailyTarget(_pet);
    final consumedKcal = summary?.completedKcal ?? 0;
    final progressPercent = dailyTarget > 0
        ? ((consumedKcal / dailyTarget) * 100).round().clamp(0, 100)
        : 0;
    final tipText = _planTip();

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
              const PtHeader(),
              PetSwitcherBar(
                pets: _scope?.pets ?? [],
                activePetId: _scope?.activePetId,
                onSelected: (id) => _scope!.selectPet(id),
              ),
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
                  '$petName için günlük kalori ve öğün planı.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(_error!, style: const TextStyle(color: AppColors.urgent, fontSize: 13)),
                ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else ...[
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
                    child: Row(
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
                                    '$dailyTarget',
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
                                        widthFactor: (progressPercent / 100).clamp(0.0, 1.0),
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
                                  '$progressPercent%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary.withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: _Macro(label: 'Protein', value: '${summary?.proteinG ?? 0}g')),
                                  Expanded(child: _Macro(label: 'Yağ', value: '${summary?.fatG ?? 0}g')),
                                  Expanded(child: _Macro(label: 'Lif', value: '${summary?.fiberG ?? 0}g')),
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
                            Text(
                              (progressPercent) >= 70 ? 'Dengeli' : 'Devam',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Diyet Hedefleri',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Haftalık Odak',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _focus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF4F6F8),
                            suffixIcon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary.withValues(alpha: 0.95),
                            ),
                          ),
                          items: _focusOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _focus = v ?? _focus),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Öğün Sayısı',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _MealCountChip(
                                label: '2',
                                selected: _mealCount == 2,
                                onTap: () => setState(() => _mealCount = 2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MealCountChip(
                                label: '3',
                                selected: _mealCount == 3,
                                onTap: () => setState(() => _mealCount = 3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MealCountChip(
                                label: '4',
                                selected: _mealCount == 4,
                                onTap: () => setState(() => _mealCount = 4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PtGradientButton(
                          label: 'Planı Güncelle',
                          onPressed: _applyPlan,
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
                          'Öğün Planlayıcı',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addMeal,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text(
                          'Yeni Öğün Ekle',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_meals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showAllMeals,
                        child: const Text(
                          'Hepsini Gör',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                if (_meals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Henüz öğün yok.', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ..._meals.take(5).map(_buildMealCard),
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
                                tipText,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCountChip extends StatelessWidget {
  const _MealCountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderSoft,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 68,
                          height: 68,
                          color: const Color(0xFFE8EAED),
                          alignment: Alignment.center,
                          child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 28),
                        ),
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
