import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pet_models.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Map<String, dynamic> _decode(http.Response res) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  void _throwIfError(http.Response res, Map<String, dynamic> data, String fallback) {
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? fallback);
    }
  }

  Future<List<Pet>> getPets() async {
    final res = await http
        .get(Uri.parse(ApiConfig.nextApi('/api/pets')))
        .timeout(const Duration(seconds: 8));
    final data = _decode(res);
    _throwIfError(res, data, 'Profiller alınamadı');
    final list = data['pets'] as List<dynamic>? ?? [];
    return list.map((e) => Pet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Pet> createPet({
    required String name,
    String species = 'CAT',
    String gender = 'UNKNOWN',
    String? breed,
    double? weight,
    DateTime? birthDate,
    String? imageUrl,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.nextApi('/api/pets')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'ownerId': ApiConfig.defaultOwnerId,
        'species': species,
        'gender': gender,
        if (breed != null && breed.isNotEmpty) 'breed': breed,
        if (weight != null) 'weight': weight,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );
    final data = _decode(res);
    if (res.statusCode != 201 || data['pet'] == null) {
      throw Exception(data['error'] ?? 'Profil oluşturulamadı');
    }
    return Pet.fromJson(data['pet'] as Map<String, dynamic>);
  }

  Future<Pet> updatePet(String id, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse(ApiConfig.nextApi('/api/pets/$id')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = _decode(res);
    if (res.statusCode != 200 || data['pet'] == null) {
      throw Exception(data['error'] ?? 'Profil güncellenemedi');
    }
    return Pet.fromJson(data['pet'] as Map<String, dynamic>);
  }

  Future<void> deletePet(String id) async {
    final res = await http.delete(Uri.parse(ApiConfig.nextApi('/api/pets/$id')));
    final data = _decode(res);
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Profil silinemedi');
    }
  }

  Future<String> uploadImage(List<int> bytes, String filename) async {
    final req = http.MultipartRequest('POST', Uri.parse(ApiConfig.nextApi('/api/uploads')));
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    final data = _decode(res);
    if (res.statusCode != 200 || data['fileUrl'] == null) {
      throw Exception(data['error'] ?? 'Resim yüklenemedi');
    }
    return data['fileUrl'] as String;
  }

  Future<List<SymptomLog>> getSymptoms({String? petId, int limit = 20}) async {
    final query = petId != null ? '?petId=$petId&limit=$limit' : '?limit=$limit';
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/symptoms$query')));
    final data = _decode(res);
    _throwIfError(res, data, 'Günlük kayıtları alınamadı');
    final list = data['items'] as List<dynamic>? ?? [];
    return list.map((e) => SymptomLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createSymptom({
    required String petId,
    required String symptom,
    required String severity,
    String? description,
    DateTime? createdAt,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.nextApi('/api/symptoms')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'petId': petId,
        'symptom': symptom,
        'severity': severity,
        if (description != null && description.isNotEmpty) 'description': description,
        if (createdAt != null) 'createdAt': createdAt.toIso8601String(),
      }),
    );
    final data = _decode(res);
    if (res.statusCode != 201) {
      throw Exception(data['error'] ?? 'Kayıt oluşturulamadı');
    }
  }

  Future<String> exportSymptoms({String? petId}) async {
    final query = petId != null ? '?petId=$petId' : '';
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/symptoms/export$query')));
    if (res.statusCode != 200) {
      final data = _decode(res);
      throw Exception(data['error'] ?? 'Dışa aktarma başarısız');
    }
    return res.body;
  }

  Future<({List<VaccinationEvent> events, List<VaccinationEvent> reminders})> getCalendar({
    required String month,
    String? petId,
  }) async {
    final query = petId != null ? '?month=$month&petId=$petId' : '?month=$month';
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/calendar$query')));
    final data = _decode(res);
    _throwIfError(res, data, 'Takvim alınamadı');
    final events = (data['events'] as List<dynamic>? ?? [])
        .map((e) => VaccinationEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final reminders = (data['reminders'] as List<dynamic>? ?? [])
        .map((e) => VaccinationEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return (events: events, reminders: reminders);
  }

  Future<VaccinationEvent> createCalendarEvent({
    required String petId,
    required String name,
    required DateTime date,
    String? notes,
    String status = 'PENDING',
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.nextApi('/api/calendar')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'petId': petId,
        'name': name,
        'date': date.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'status': status,
      }),
    );
    final data = _decode(res);
    if (res.statusCode != 201 || data['event'] == null) {
      throw Exception(data['error'] ?? 'Hatırlatıcı eklenemedi');
    }
    return VaccinationEvent.fromJson(data['event'] as Map<String, dynamic>);
  }

  Future<VaccinationEvent> updateCalendarEvent(String id, {required String status}) async {
    final res = await http.patch(
      Uri.parse(ApiConfig.nextApi('/api/calendar/$id')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    final data = _decode(res);
    if (res.statusCode != 200 || data['event'] == null) {
      throw Exception(data['error'] ?? 'Hatırlatıcı güncellenemedi');
    }
    return VaccinationEvent.fromJson(data['event'] as Map<String, dynamic>);
  }

  Future<List<NutritionItem>> getNutrition({String? petId}) async {
    final query = petId != null ? '?petId=$petId' : '';
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/nutrition$query')));
    final data = _decode(res);
    _throwIfError(res, data, 'Beslenme kayıtları alınamadı');
    final list = data['items'] as List<dynamic>? ?? [];
    return list.map((e) => NutritionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<NutritionSummary> getNutritionSummary(String petId) async {
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/nutrition/summary?petId=$petId')));
    final data = _decode(res);
    if (res.statusCode != 200 || data['summary'] == null) {
      throw Exception(data['error'] ?? 'Beslenme özeti alınamadı');
    }
    return NutritionSummary.fromJson(data['summary'] as Map<String, dynamic>);
  }

  Future<NutritionItem> createNutrition({
    required String petId,
    required String foodName,
    required String amount,
    required String feedTime,
    int frequency = 1,
    String status = 'PENDING',
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.nextApi('/api/nutrition')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'petId': petId,
        'foodName': foodName,
        'amount': amount,
        'feedTime': feedTime,
        'frequency': frequency,
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    final data = _decode(res);
    if (res.statusCode != 201 || data['item'] == null) {
      throw Exception(data['error'] ?? 'Öğün eklenemedi');
    }
    return NutritionItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<NutritionItem> updateNutrition(String id, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse(ApiConfig.nextApi('/api/nutrition/$id')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = _decode(res);
    if (res.statusCode != 200 || data['item'] == null) {
      throw Exception(data['error'] ?? 'Öğün güncellenemedi');
    }
    return NutritionItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<ChatMeta> getChatMeta({String? petId}) async {
    final query = petId != null && petId.isNotEmpty ? '?petId=${Uri.encodeQueryComponent(petId)}' : '';
    final res = await http.get(Uri.parse(ApiConfig.nextApi('/api/chat$query')));
    final data = _decode(res);
    _throwIfError(res, data, 'Asistan bilgisi alınamadı');
    return ChatMeta.fromJson(data);
  }

  Future<String> chat(String message, List<ChatMessage> history, {String? petId}) async {
    final res = await http.post(
      Uri.parse(ApiConfig.nextApi('/api/chat')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'history': history.map((m) => m.toJson()).toList(),
        if (petId != null && petId.isNotEmpty) 'petId': petId,
      }),
    );
    final data = _decode(res);
    if (res.statusCode != 200 || data['reply'] == null) {
      throw Exception(data['error'] ?? 'Yanıt alınamadı');
    }
    return data['reply'] as String;
  }
}
