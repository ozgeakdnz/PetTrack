class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.imageUrl,
    required this.gender,
    this.birthDate,
    this.weight,
    required this.ownerId,
  });

  final String id;
  final String name;
  final String species;
  final String? breed;
  final String? imageUrl;
  final String gender;
  final DateTime? birthDate;
  final double? weight;
  final String ownerId;

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      imageUrl: json['imageUrl'] as String?,
      gender: json['gender'] as String,
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate'] as String) : null,
      weight: (json['weight'] as num?)?.toDouble(),
      ownerId: json['ownerId'] as String,
    );
  }

  String get speciesLabel {
    switch (species) {
      case 'DOG':
        return 'Köpek';
      case 'BIRD':
        return 'Kuş';
      default:
        return 'Kedi';
    }
  }

  String get genderLabel {
    switch (gender) {
      case 'MALE':
        return 'Erkek';
      case 'FEMALE':
        return 'Dişi';
      default:
        return 'Bilinmiyor';
    }
  }

  String get ageLabel {
    if (birthDate == null) return '—';
    final now = DateTime.now();
    var years = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    if (years < 1) return '1 yaş altı';
    return '$years Yaş';
  }
}

class SymptomLog {
  const SymptomLog({
    required this.id,
    required this.symptom,
    this.description,
    required this.severity,
    required this.createdAt,
  });

  final String id;
  final String symptom;
  final String? description;
  final String severity;
  final DateTime createdAt;

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'] as String,
      symptom: json['symptom'] as String,
      description: json['description'] as String?,
      severity: json['severity'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class VaccinationEvent {
  const VaccinationEvent({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.notes,
    this.petId,
    this.petName,
  });

  final String id;
  final String name;
  final DateTime date;
  final String status;
  final String? notes;
  final String? petId;
  final String? petName;

  factory VaccinationEvent.fromJson(Map<String, dynamic> json) {
    return VaccinationEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      petId: json['petId'] as String?,
      petName: json['petName'] as String?,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
}

class NutritionItem {
  const NutritionItem({
    required this.id,
    required this.foodName,
    required this.amount,
    required this.feedTime,
    required this.status,
    this.notes,
    this.frequency = 1,
  });

  final String id;
  final String foodName;
  final String amount;
  final String feedTime;
  final String status;
  final String? notes;
  final int frequency;

  factory NutritionItem.fromJson(Map<String, dynamic> json) {
    return NutritionItem(
      id: json['id'] as String,
      foodName: json['foodName'] as String,
      amount: json['amount'] as String,
      feedTime: json['feedTime'] as String? ?? '08:30',
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      frequency: (json['frequency'] as num?)?.toInt() ?? 1,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
}

class NutritionSummary {
  const NutritionSummary({
    required this.petName,
    required this.dailyTargetKcal,
    required this.completedKcal,
    required this.progressPercent,
    required this.proteinG,
    required this.fatG,
    required this.fiberG,
    required this.tip,
    required this.mealCount,
    required this.completedMealCount,
  });

  final String petName;
  final int dailyTargetKcal;
  final int completedKcal;
  final int progressPercent;
  final int proteinG;
  final int fatG;
  final int fiberG;
  final String tip;
  final int mealCount;
  final int completedMealCount;

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    return NutritionSummary(
      petName: json['petName'] as String? ?? 'Pati Dostu',
      dailyTargetKcal: (json['dailyTargetKcal'] as num?)?.toInt() ?? 840,
      completedKcal: (json['completedKcal'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      fatG: (json['fatG'] as num?)?.toInt() ?? 0,
      fiberG: (json['fiberG'] as num?)?.toInt() ?? 0,
      tip: json['tip'] as String? ?? '',
      mealCount: (json['mealCount'] as num?)?.toInt() ?? 0,
      completedMealCount: (json['completedMealCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ChatMeta {
  const ChatMeta({
    required this.assistant,
    required this.suggestions,
    required this.disclaimer,
  });

  final String assistant;
  final List<String> suggestions;
  final String disclaimer;

  factory ChatMeta.fromJson(Map<String, dynamic> json) {
    return ChatMeta(
      assistant: json['assistant'] as String? ?? 'Pati Dostu',
      suggestions: (json['suggestions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}

class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}
