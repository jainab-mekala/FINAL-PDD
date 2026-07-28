import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../models/implant_model.dart';
import '../models/assessment_model.dart';

class PatientService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _patients => _db.collection('patients');
  CollectionReference get _implants => _db.collection('implants');
  CollectionReference get _assessments => _db.collection('assessments');

  // ============= PATIENTS =============

  Stream<List<Patient>> watchPatients(String doctorId) {
    return _patients
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Patient.fromFirestore(doc)).toList());
  }

  Future<Patient?> getPatient(String patientId) async {
    final doc = await _patients.doc(patientId).get();
    if (!doc.exists) return null;
    return Patient.fromFirestore(doc);
  }

  Future<String> addPatient(Patient patient) async {
    final ref = await _patients.add(patient.toFirestore());
    return ref.id;
  }

  Future<void> updatePatient(Patient patient) async {
    await _patients.doc(patient.id).update(patient.toFirestore());
  }

  Future<void> deletePatient(String patientId) async {
    // Cascade delete implants and assessments
    final batch = _db.batch();

    final implants = await _implants
        .where('patientId', isEqualTo: patientId)
        .get();

    for (final implant in implants.docs) {
      // Delete assessments for this implant
      final assessments = await _assessments
          .where('implantId', isEqualTo: implant.id)
          .get();

      for (final assessment in assessments.docs) {
        batch.delete(assessment.reference);
      }

      batch.delete(implant.reference);
    }

    batch.delete(_patients.doc(patientId));
    await batch.commit();
  }

  Future<List<Patient>> searchPatients(String doctorId, String query) async {
    final q = query.toLowerCase();
    final all = await _patients
        .where('doctorId', isEqualTo: doctorId)
        .get();

    return all.docs
        .map((doc) => Patient.fromFirestore(doc))
        .where((p) =>
            p.fullName.toLowerCase().contains(q) ||
            (p.email?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  // ============= IMPLANTS =============

  Stream<List<Implant>> watchImplantsForPatient(String patientId) {
    return _implants
        .where('patientId', isEqualTo: patientId)
        .orderBy('placementDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Implant.fromFirestore(doc)).toList());
  }

  Stream<List<Implant>> watchAllImplants(String doctorId) {
    return _implants
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Implant.fromFirestore(doc)).toList());
  }

  Future<Implant?> getImplant(String implantId) async {
    final doc = await _implants.doc(implantId).get();
    if (!doc.exists) return null;
    return Implant.fromFirestore(doc);
  }

  Future<String> addImplant(Implant implant) async {
    final batch = _db.batch();
    final ref = _implants.doc();

    batch.set(ref, implant.toFirestore());

    // Update patient's implantIds
    batch.update(_patients.doc(implant.patientId), {
      'implantIds': FieldValue.arrayUnion([ref.id]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
    return ref.id;
  }

  Future<void> updateImplant(Implant implant) async {
    await _implants.doc(implant.id).update(implant.toFirestore());
  }

  Future<void> updateImplantStatus(
    String implantId,
    ImplantStatus status,
    double riskScore,
  ) async {
    await _implants.doc(implantId).update({
      'currentStatus': status.name,
      'riskScore': riskScore,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ============= ASSESSMENTS =============

  Stream<List<Assessment>> watchAssessmentsForImplant(String implantId) {
    return _assessments
        .where('implantId', isEqualTo: implantId)
        .orderBy('assessmentDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Assessment.fromFirestore(doc)).toList());
  }

  Future<List<Assessment>> getAssessmentHistory(String implantId) async {
    final snap = await _assessments
        .where('implantId', isEqualTo: implantId)
        .orderBy('assessmentDate', descending: true)
        .get();

    return snap.docs.map((doc) => Assessment.fromFirestore(doc)).toList();
  }

  Future<String> addAssessment(Assessment assessment) async {
    final batch = _db.batch();
    final ref = _assessments.doc();

    batch.set(ref, assessment.toFirestore());

    // Update implant's assessmentIds
    batch.update(_implants.doc(assessment.implantId), {
      'assessmentIds': FieldValue.arrayUnion([ref.id]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await batch.commit();
    return ref.id;
  }

  Future<void> updateAssessmentWithAIPrediction(
    String assessmentId,
    double riskScore,
    String riskCategory,
    List<String> recommendations,
    Map<String, double> featureImportance,
  ) async {
    await _assessments.doc(assessmentId).update({
      'predictedRiskScore': riskScore,
      'riskCategory': riskCategory,
      'aiRecommendations': recommendations,
      'featureImportance': featureImportance,
    });
  }

  // ============= ANALYTICS =============

  Future<Map<String, int>> getDashboardStats(String doctorId) async {
    final patients = await _patients.where('doctorId', isEqualTo: doctorId).count().get();
    final implants = await _implants.where('doctorId', isEqualTo: doctorId).count().get();
    final critical = await _implants
        .where('doctorId', isEqualTo: doctorId)
        .where('currentStatus', whereIn: ['critical', 'atRisk'])
        .count()
        .get();

    return {
      'patients': patients.count ?? 0,
      'implants': implants.count ?? 0,
      'critical': critical.count ?? 0,
    };
  }

  Stream<List<Implant>> watchCriticalImplants(String doctorId) {
    return _implants
        .where('doctorId', isEqualTo: doctorId)
        .where('currentStatus', whereIn: ['critical', 'atRisk'])
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Implant.fromFirestore(doc)).toList());
  }
}
