import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/pet_models.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'pt_gradient_button.dart';

/// Yeni evcil hayvan ekleme formu.
Future<Pet?> showAddPetSheet(BuildContext context) {
  return showModalBottomSheet<Pet>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _AddPetSheet(),
  );
}

class _AddPetSheet extends StatefulWidget {
  const _AddPetSheet();

  @override
  State<_AddPetSheet> createState() => _AddPetSheetState();
}

class _AddPetSheetState extends State<_AddPetSheet> {
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  String _species = 'CAT';
  String _gender = 'UNKNOWN';
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İsim zorunludur')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final pet = await ApiService.instance.createPet(
        name: name,
        species: _species,
        gender: _gender,
        breed: _breedCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(pet);
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Yeni Evcil Hayvan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'İsim *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _breedCtrl,
            decoration: const InputDecoration(labelText: 'Irk'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _species,
            decoration: const InputDecoration(labelText: 'Tür'),
            items: const [
              DropdownMenuItem(value: 'CAT', child: Text('Kedi')),
              DropdownMenuItem(value: 'DOG', child: Text('Köpek')),
              DropdownMenuItem(value: 'BIRD', child: Text('Kuş')),
            ],
            onChanged: (v) => setState(() => _species = v ?? 'CAT'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Cinsiyet'),
            items: const [
              DropdownMenuItem(value: 'MALE', child: Text('Erkek')),
              DropdownMenuItem(value: 'FEMALE', child: Text('Dişi')),
              DropdownMenuItem(value: 'UNKNOWN', child: Text('Bilinmiyor')),
            ],
            onChanged: (v) => setState(() => _gender = v ?? 'UNKNOWN'),
          ),
          const SizedBox(height: 20),
          PtGradientButton(
            label: _saving ? 'Kaydediliyor...' : 'Profil Oluştur',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Takvim hatırlatıcısı ekleme.
Future<bool?> showAddCalendarSheet(BuildContext context, {required String petId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _AddCalendarSheet(petId: petId),
  );
}

class _AddCalendarSheet extends StatefulWidget {
  const _AddCalendarSheet({required this.petId});

  final String petId;

  @override
  State<_AddCalendarSheet> createState() => _AddCalendarSheetState();
}

class _AddCalendarSheetState extends State<_AddCalendarSheet> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    if (time == null) return;
    setState(() {
      _date = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aşı/randevu adı zorunludur')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.instance.createCalendarEvent(
        petId: widget.petId,
        name: name,
        date: _date,
        notes: _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final dateLabel = DateFormat('d MMM yyyy, HH:mm', 'tr_TR').format(_date);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Hatırlatıcı Ekle', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Aşı / Randevu adı *'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Tarih ve saat'),
              child: Text(dateLabel),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Not (klinik, konum vb.)'),
          ),
          const SizedBox(height: 20),
          PtGradientButton(
            label: _saving ? 'Kaydediliyor...' : 'Hatırlatıcı Kaydet',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Beslenme öğünü ekleme.
Future<bool?> showAddNutritionSheet(BuildContext context, {required String petId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _AddNutritionSheet(petId: petId),
  );
}

class _AddNutritionSheet extends StatefulWidget {
  const _AddNutritionSheet({required this.petId});

  final String petId;

  @override
  State<_AddNutritionSheet> createState() => _AddNutritionSheetState();
}

class _AddNutritionSheetState extends State<_AddNutritionSheet> {
  final _foodCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 30);
  bool _saving = false;

  @override
  void dispose() {
    _foodCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final food = _foodCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    if (food.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mama adı ve miktar zorunludur')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final feedTime =
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      await ApiService.instance.createNutrition(
        petId: widget.petId,
        foodName: food,
        amount: amount,
        feedTime: feedTime,
      );
      if (mounted) Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Öğün Ekle', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 16),
          TextField(
            controller: _foodCtrl,
            decoration: const InputDecoration(labelText: 'Mama adı *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            decoration: const InputDecoration(labelText: 'Miktar (ör. 210 gr) *'),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Saat'),
              child: Text(_time.format(context)),
            ),
          ),
          const SizedBox(height: 20),
          PtGradientButton(
            label: _saving ? 'Kaydediliyor...' : 'Öğün Kaydet',
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

/// Liste alt sayfası — tüm öğeleri gösterir.
void showAllItemsSheet(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.35,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.only(bottom: 24),
                children: children,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Bildirimler — yaklaşan hatırlatıcılar.
void showNotificationsSheet(BuildContext context, List<VaccinationEvent> reminders) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              Text('Yaklaşan hatırlatıcı yok.', style: TextStyle(color: AppColors.textSecondary))
            else
              ...reminders.take(8).map((r) {
                final dt = DateFormat('d MMM, HH:mm', 'tr_TR').format(r.date.toLocal());
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    r.isCompleted ? Icons.check_circle_outline : Icons.notifications_none_rounded,
                    color: r.isCompleted ? AppColors.textSecondary : AppColors.primary,
                  ),
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${r.petName ?? ''} • $dt'),
                );
              }),
          ],
        ),
      );
    },
  );
}
