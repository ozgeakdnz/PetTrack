import 'package:flutter/material.dart';

import '../models/pet_models.dart';
import '../services/api_service.dart';

/// Uygulama genelinde aktif evcil hayvan seçimi (web'deki activePetId ile aynı mantık).
class ActivePetScope extends ChangeNotifier {
  List<Pet> _pets = [];
  String? _activePetId;
  bool _loading = false;
  String? _error;

  List<Pet> get pets => List.unmodifiable(_pets);
  String? get activePetId => _activePetId;
  bool get loading => _loading;
  String? get error => _error;

  Pet? get activePet {
    if (_activePetId == null) return null;
    for (final pet in _pets) {
      if (pet.id == _activePetId) return pet;
    }
    return null;
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await ApiService.instance.getPets();
      _pets = loaded;
      if (_activePetId == null || !_pets.any((p) => p.id == _activePetId)) {
        _activePetId = _pets.isNotEmpty ? _pets.first.id : null;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _pets = [];
      _activePetId = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectPet(String petId) {
    if (!_pets.any((p) => p.id == petId)) return;
    _activePetId = petId;
    notifyListeners();
  }

  void upsertPet(Pet pet) {
    final idx = _pets.indexWhere((p) => p.id == pet.id);
    if (idx >= 0) {
      _pets[idx] = pet;
    } else {
      _pets = [pet, ..._pets];
    }
    _activePetId = pet.id;
    notifyListeners();
  }

  Future<Pet> addPet({
    required String name,
    String species = 'CAT',
    String gender = 'UNKNOWN',
    String? breed,
  }) async {
    final pet = await ApiService.instance.createPet(
      name: name,
      species: species,
      gender: gender,
      breed: breed,
    );
    upsertPet(pet);
    return pet;
  }
}

class ActivePetScopeWidget extends StatefulWidget {
  const ActivePetScopeWidget({super.key, required this.child});

  final Widget child;

  static ActivePetScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_InheritedActivePetScope>();
    assert(scope != null, 'ActivePetScopeWidget bulunamadı');
    return scope!.notifier!;
  }

  static ActivePetScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedActivePetScope>()?.notifier;
  }

  @override
  State<ActivePetScopeWidget> createState() => _ActivePetScopeWidgetState();
}

class _ActivePetScopeWidgetState extends State<ActivePetScopeWidget> {
  final ActivePetScope _scope = ActivePetScope();

  @override
  void initState() {
    super.initState();
    _scope.refresh();
  }

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedActivePetScope(
      notifier: _scope,
      child: widget.child,
    );
  }
}

class _InheritedActivePetScope extends InheritedNotifier<ActivePetScope> {
  const _InheritedActivePetScope({required super.notifier, required super.child});
}
