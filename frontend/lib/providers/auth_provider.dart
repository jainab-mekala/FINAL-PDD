import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/patient_service.dart';
import '../services/ai_prediction_service.dart';
import '../services/report_storage_service.dart';

import '../models/patient_model.dart';
import '../models/implant_model.dart';
import '../models/assessment_model.dart';

const String PUBLIC_USER_ID = 'public_access_user';

// ============= AUTH =============

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider = FutureProvider.autoDispose((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  final uid = user?.uid ?? PUBLIC_USER_ID;
  return ref.watch(authServiceProvider).getUserProfile(uid);
});

// ============= SERVICES =============

final patientServiceProvider = Provider.autoDispose<PatientService>((ref) => PatientService());
final aiServiceProvider = Provider.autoDispose<AIPredictionService>((ref) => AIPredictionService());

// ============= PATIENTS =============

final patientsStreamProvider = StreamProvider.autoDispose<List<Patient>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final uid = user?.uid ?? PUBLIC_USER_ID;
  return ref.watch(patientServiceProvider).watchPatients(uid);
});

final patientProvider = FutureProvider.autoDispose.family<Patient?, String>((ref, id) async {
  return ref.watch(patientServiceProvider).getPatient(id);
});

// ============= IMPLANTS =============

final implantsByPatientProvider = StreamProvider.autoDispose.family<List<Implant>, String>(
  (ref, patientId) {
    return ref.watch(patientServiceProvider).watchImplantsForPatient(patientId);
  },
);

final allImplantsProvider = StreamProvider.autoDispose<List<Implant>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final uid = user?.uid ?? PUBLIC_USER_ID;
  return ref.watch(patientServiceProvider).watchAllImplants(uid);
});

final implantProvider = FutureProvider.autoDispose.family<Implant?, String>((ref, id) async {
  return ref.watch(patientServiceProvider).getImplant(id);
});

final criticalImplantsProvider = StreamProvider.autoDispose<List<Implant>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final uid = user?.uid ?? PUBLIC_USER_ID;
  return ref.watch(patientServiceProvider).watchCriticalImplants(uid);
});

// ============= ASSESSMENTS =============

final assessmentsForImplantProvider = StreamProvider.autoDispose.family<List<Assessment>, String>(
  (ref, implantId) {
    return ref.watch(patientServiceProvider).watchAssessmentsForImplant(implantId);
  },
);

// ============= DASHBOARD STATS =============

final dashboardStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  final uid = user?.uid ?? PUBLIC_USER_ID;

  // 1. Get Firestore stats
  final stats = await ref.watch(patientServiceProvider).getDashboardStats(uid);

  // 2. Get ReportStorageService stats (all historical predictions)
  final allReports = await ReportStorageService.loadAllHistory();
  
  int historyTotal = allReports.length;
  int historyCritical = 0;

  for (final item in allReports) {
    try {
      final score = (item['score'] as num?)?.toDouble() ?? 0.0;
      if (score >= 0.75) historyCritical++;
    } catch (_) {}
  }

  return {
    'patients': stats['patients'] ?? 0,
    'implants': (stats['implants'] ?? 0) + historyTotal,
    'critical': (stats['critical'] ?? 0) + historyCritical,
  };
});


// ============= SEARCH =============

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => this.state = value;
}

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredPatientsProvider = Provider.autoDispose<List<Patient>>((ref) {
  final patients = ref.watch(patientsStreamProvider).asData?.value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return patients;

  return patients.where((p) =>
    p.fullName.toLowerCase().contains(query) ||
    (p.email?.toLowerCase().contains(query) ?? false)
  ).toList();
});

// ============= LOADING STATES =============

class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => this.state = value;
}

final isLoadingProvider = NotifierProvider.autoDispose<LoadingNotifier, bool>(LoadingNotifier.new);
