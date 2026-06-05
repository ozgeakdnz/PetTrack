import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../config/api_config.dart';
import '../models/pet_models.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../state/active_pet_scope.dart';
import '../widgets/pet_switcher_bar.dart';
import '../widgets/pt_action_sheets.dart';
import '../widgets/pt_gradient_button.dart';
import '../widgets/pt_header.dart';
import '../widgets/pt_screen_shell.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ActivePetScope? _scope;
  String? _formPetId;
  bool _saving = false;

  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  String _species = 'CAT';
  String _gender = 'UNKNOWN';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scope?.removeListener(_onScopeChanged);
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _breedCtrl.dispose();
    _birthCtrl.dispose();
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
      _syncForm(force: true);
    }
  }

  void _onScopeChanged() {
    if (!mounted) return;
    if (_scope!.activePetId != _formPetId) {
      _syncForm(force: true);
    }
    setState(() {});
  }

  void _syncForm({bool force = false}) {
    final pet = _scope?.activePet;
    if (pet == null) {
      _formPetId = null;
      return;
    }
    if (!force && pet.id == _formPetId) return;
    _formPetId = pet.id;
    _nameCtrl.text = pet.name;
    _species = pet.species;
    _gender = pet.gender;
    _weightCtrl.text = pet.weight?.toString() ?? '';
    _breedCtrl.text = pet.breed ?? '';
    _birthCtrl.text = pet.birthDate != null
        ? DateFormat('dd/MM/yyyy').format(pet.birthDate!.toLocal())
        : '';
  }

  Pet? get _pet => _scope?.activePet;
  bool get _loading => _scope?.loading ?? true;
  String? get _error => _scope?.error;

  Future<void> _load() => _scope!.refresh();

  ImageProvider? get _avatarImage {
    final url = _pet?.imageUrl;
    if (url == null || url.isEmpty) {
      return const AssetImage('assets/images/pamuk_avatar.png');
    }
    if (url.startsWith('http')) return NetworkImage(url);
    return NetworkImage('${ApiConfig.nextApiBase}$url');
  }

  Future<void> _pickImage() async {
    if (_pet == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    setState(() => _saving = true);
    try {
      final bytes = await file.readAsBytes();
      final fileUrl = await ApiService.instance.uploadImage(bytes, file.name);
      final updated = await ApiService.instance.updatePet(_pet!.id, {'imageUrl': fileUrl});
      _scope!.upsertPet(updated);
      _syncForm(force: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil resmi güncellendi')),
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

  Future<void> _pickBirthDate() async {
    final initial = _pet?.birthDate?.toLocal() ?? DateTime(2022, 5, 12);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _birthCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_pet == null) return;
    setState(() => _saving = true);
    try {
      final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
      final name = _nameCtrl.text.trim();
      if (name.isEmpty) {
        throw Exception('İsim zorunludur');
      }
      final updated = await ApiService.instance.updatePet(_pet!.id, {
        'name': name,
        'species': _species,
        'gender': _gender,
        'weight': weight,
        'breed': _breedCtrl.text.trim(),
        if (_birthCtrl.text.isNotEmpty) 'birthDate': _parseBirth(_birthCtrl.text),
      });
      _scope!.upsertPet(updated);
      _syncForm(force: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil bilgileri kaydedildi')),
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

  String _parseBirth(String text) {
    try {
      final parts = text.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])).toIso8601String();
      }
    } catch (_) {}
    return DateTime.now().toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return PtScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PtHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: Text(_error!, style: const TextStyle(color: AppColors.urgent, fontSize: 13)),
                            ),
                          PetSwitcherBar(
                            pets: _scope?.pets ?? [],
                            activePetId: _scope?.activePetId,
                            onSelected: (id) => _scope!.selectPet(id),
                            onAddPet: _addPet,
                          ),
                          if (_pet == null)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  'Henüz evcil hayvan profili yok.\nBackend çalışıyor mu kontrol edin (npm run dev).',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                                ),
                              ),
                            )
                          else ...[
                            _PetProfileCard(
                              pet: _pet!,
                              avatarImage: _avatarImage,
                              saving: _saving,
                              onEditPhoto: _pickImage,
                            ),
                            const SizedBox(height: 24),
                            _UpdateSectionHeader(),
                            const SizedBox(height: 14),
                            _UpdateForm(
                              nameCtrl: _nameCtrl,
                              weightCtrl: _weightCtrl,
                              breedCtrl: _breedCtrl,
                              birthCtrl: _birthCtrl,
                              species: _species,
                              gender: _gender,
                              onSpeciesChanged: (v) => setState(() => _species = v),
                              onGenderChanged: (v) => setState(() => _gender = v),
                              onPickBirthDate: _pickBirthDate,
                            ),
                            const SizedBox(height: 18),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.28),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: PtGradientButton(
                                  label: _saving ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet',
                                  onPressed: _saving ? null : _save,
                                ),
                              ),
                            ),
                          ],
                          if (_pet != null) const SizedBox(height: 14),
                          if (_pet == null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _AddPetButton(onTap: _addPet),
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

  Future<void> _addPet() async {
    final pet = await showAddPetSheet(context);
    if (pet != null) {
      _scope!.upsertPet(pet);
      _syncForm(force: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pet.name} profili oluşturuldu — bilgileri düzenleyebilirsiniz')),
        );
      }
    }
  }
}

/// Üst profil kartı — avatar kartın üst kenarına taşar (mockup).
class _PetProfileCard extends StatelessWidget {
  const _PetProfileCard({
    required this.pet,
    required this.avatarImage,
    required this.saving,
    required this.onEditPhoto,
  });

  final Pet pet;
  final ImageProvider? avatarImage;
  final bool saving;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final subtitle = '${pet.ageLabel} • ${pet.genderLabel} • ${pet.breed ?? 'Irk belirtilmedi'}';
    final weightText = pet.weight != null ? '${pet.weight} kg' : '—';
    final birthText = pet.birthDate != null
        ? DateFormat('d MMM yyyy', 'tr_TR').format(pet.birthDate!.toLocal())
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 52),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 68, 20, 22),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.monitor_weight_outlined,
                          label: 'KİLO',
                          value: weightText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.cake_outlined,
                          label: 'DOĞUM GÜNÜ',
                          value: birthText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFFE8EAED),
                    backgroundImage: avatarImage,
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 4,
                  child: GestureDetector(
                    onTap: saving ? null : onEditPhoto,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: saving
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateSectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'Bilgileri Güncelle',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            'Son Güncelleme: 3 gün önce',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateForm extends StatelessWidget {
  const _UpdateForm({
    required this.nameCtrl,
    required this.weightCtrl,
    required this.breedCtrl,
    required this.birthCtrl,
    required this.species,
    required this.gender,
    required this.onSpeciesChanged,
    required this.onGenderChanged,
    required this.onPickBirthDate,
  });

  final TextEditingController nameCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController breedCtrl;
  final TextEditingController birthCtrl;
  final String species;
  final String gender;
  final ValueChanged<String> onSpeciesChanged;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onPickBirthDate;

  static const _fieldFill = Color(0xFFF0F2F4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF1F3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: 'İsim',
              child: TextFormField(
                controller: nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Tür',
              child: DropdownButtonFormField<String>(
                value: species,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'CAT', child: Text('Kedi')),
                  DropdownMenuItem(value: 'DOG', child: Text('Köpek')),
                  DropdownMenuItem(value: 'BIRD', child: Text('Kuş')),
                ],
                onChanged: (v) => onSpeciesChanged(v ?? 'CAT'),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Cinsiyet',
              child: DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'FEMALE', child: Text('Dişi')),
                  DropdownMenuItem(value: 'MALE', child: Text('Erkek')),
                  DropdownMenuItem(value: 'UNKNOWN', child: Text('Bilinmiyor')),
                ],
                onChanged: (v) => onGenderChanged(v ?? 'UNKNOWN'),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Güncel Ağırlık (kg)',
              child: TextFormField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      'kg',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Irk',
              child: TextFormField(
                controller: breedCtrl,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Doğum Tarihi',
              child: TextFormField(
                controller: birthCtrl,
                readOnly: true,
                onTap: onPickBirthDate,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _fieldFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

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
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _AddPetButton extends StatelessWidget {
  const _AddPetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F6F8),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.borderSoft,
            radius: 24,
            strokeWidth: 1.5,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.add, size: 18, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Yeni Evcil Hayvan Ekle',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 6;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + 4;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
