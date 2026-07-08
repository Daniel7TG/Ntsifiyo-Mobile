import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_database.dart';
import '../../data/models/models.dart';
import '../../data/services/activity_service.dart';
import '../auth/auth_controller.dart';

/// Dashboard según el rol, con copia cacheada en disco para modo offline.
final dashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authControllerProvider);
  final service = ref.read(activityServiceProvider);
  final db = ref.read(appDatabaseProvider);
  final cacheKey =
      user?.isStudent == true ? 'dashboard_student' : 'dashboard_visitor';

  try {
    final data = user?.isStudent == true
        ? await service.getStudentDashboard()
        : await service.getVisitorDashboard();
    await db.kvPut(cacheKey, jsonEncode(data));
    return data;
  } catch (e) {
    // Sin red: usar la última copia guardada.
    final cached = await db.kvGet(cacheKey);
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }
    rethrow;
  }
});

/// Actividades asignadas al estudiante (paginado del backend).
final studentActivitiesProvider = FutureProvider.autoDispose
    .family<Paged<Map<String, dynamic>>, int>((ref, page) async {
  final service = ref.read(activityServiceProvider);
  final response = await service.getStudentActivities(page: page);
  return Paged.fromJson(response, (json) => json);
});
