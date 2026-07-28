import 'package:cloud_firestore/cloud_firestore.dart';

enum BleedingOnProbing { absent, present }

enum Suppuration { absent, present }

enum MobilityGrade { none, grade1, grade2, grade3 }

class ProbingDepthMeasurement {
  // Measurements in mm for 6 sites: mesio-buccal, buccal, disto-buccal,
  // mesio-lingual, lingual, disto-lingual
  final double mesialBuccal;
  final double buccal;
  final double distalBuccal;
  final double mesialLingual;
  final double lingual;
  final double distalLingual;

  ProbingDepthMeasurement({
    required this.mesialBuccal,
    required this.buccal,
    required this.distalBuccal,
    required this.mesialLingual,
    required this.lingual,
    required this.distalLingual,
  });

  double get average =>
      (mesialBuccal + buccal + distalBuccal + mesialLingual + lingual + distalLingual) / 6;

  double get max => [mesialBuccal, buccal, distalBuccal, mesialLingual, lingual, distalLingual]
      .reduce((a, b) => a > b ? a : b);

  bool get hasDeepPocket => max >= 6.0;

  factory ProbingDepthMeasurement.fromMap(Map<String, dynamic> map) {
    return ProbingDepthMeasurement(
      mesialBuccal: (map['mesialBuccal'] ?? 0.0).toDouble(),
      buccal: (map['buccal'] ?? 0.0).toDouble(),
      distalBuccal: (map['distalBuccal'] ?? 0.0).toDouble(),
      mesialLingual: (map['mesialLingual'] ?? 0.0).toDouble(),
      lingual: (map['lingual'] ?? 0.0).toDouble(),
      distalLingual: (map['distalLingual'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mesialBuccal': mesialBuccal,
      'buccal': buccal,
      'distalBuccal': distalBuccal,
      'mesialLingual': mesialLingual,
      'lingual': lingual,
      'distalLingual': distalLingual,
    };
  }
}

class Assessment {
  final String id;
  final String implantId;
  final String patientId;
  final String doctorId;
  final DateTime assessmentDate;

  // Clinical Parameters
  final ProbingDepthMeasurement probingDepths;
  final double boneLevelChange; // mm change from baseline
  final double? marginalBoneLevel; // mm from implant-abutment junction
  final BleedingOnProbing bleedingOnProbing;
  final Suppuration suppuration;
  final MobilityGrade mobility;
  final double? plaqueScore; // 0-100%
  final double? modifiedPlaqueIndex; // 0-3
  final bool mucositisPresent;
  final bool periImplantitisDetected;

  // Radiographic Parameters
  final double? crestalBoneLevel; // mm
  final bool? radiographicBoneLoss;
  final String? xrayImageUrl;

  // Symptoms
  final bool patientReportedPain;
  final bool patientReportedSwelling;
  final bool patientReportedLooseness;
  final int? painScore; // 0-10 VAS

  // AI Prediction (computed)
  final double? predictedRiskScore;
  final String? riskCategory;
  final List<String>? aiRecommendations;
  final Map<String, double>? featureImportance;

  final String? clinicalNotes;
  final DateTime createdAt;

  Assessment({
    required this.id,
    required this.implantId,
    required this.patientId,
    required this.doctorId,
    required this.assessmentDate,
    required this.probingDepths,
    required this.boneLevelChange,
    this.marginalBoneLevel,
    required this.bleedingOnProbing,
    required this.suppuration,
    required this.mobility,
    this.plaqueScore,
    this.modifiedPlaqueIndex,
    required this.mucositisPresent,
    required this.periImplantitisDetected,
    this.crestalBoneLevel,
    this.radiographicBoneLoss,
    this.xrayImageUrl,
    required this.patientReportedPain,
    required this.patientReportedSwelling,
    required this.patientReportedLooseness,
    this.painScore,
    this.predictedRiskScore,
    this.riskCategory,
    this.aiRecommendations,
    this.featureImportance,
    this.clinicalNotes,
    required this.createdAt,
  });

  bool get isCritical =>
      periImplantitisDetected ||
      (predictedRiskScore != null && predictedRiskScore! > 0.75) ||
      probingDepths.max >= 6.0 ||
      boneLevelChange >= 2.0;

  factory Assessment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Assessment(
      id: doc.id,
      implantId: data['implantId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      assessmentDate: (data['assessmentDate'] as Timestamp).toDate(),
      probingDepths: ProbingDepthMeasurement.fromMap(data['probingDepths'] ?? {}),
      boneLevelChange: (data['boneLevelChange'] ?? 0.0).toDouble(),
      marginalBoneLevel: data['marginalBoneLevel']?.toDouble(),
      bleedingOnProbing: data['bleedingOnProbing'] == 'present'
          ? BleedingOnProbing.present
          : BleedingOnProbing.absent,
      suppuration: data['suppuration'] == 'present'
          ? Suppuration.present
          : Suppuration.absent,
      mobility: MobilityGrade.values.firstWhere(
        (e) => e.name == data['mobility'],
        orElse: () => MobilityGrade.none,
      ),
      plaqueScore: data['plaqueScore']?.toDouble(),
      modifiedPlaqueIndex: data['modifiedPlaqueIndex']?.toDouble(),
      mucositisPresent: data['mucositisPresent'] ?? false,
      periImplantitisDetected: data['periImplantitisDetected'] ?? false,
      crestalBoneLevel: data['crestalBoneLevel']?.toDouble(),
      radiographicBoneLoss: data['radiographicBoneLoss'],
      xrayImageUrl: data['xrayImageUrl'],
      patientReportedPain: data['patientReportedPain'] ?? false,
      patientReportedSwelling: data['patientReportedSwelling'] ?? false,
      patientReportedLooseness: data['patientReportedLooseness'] ?? false,
      painScore: data['painScore'],
      predictedRiskScore: data['predictedRiskScore']?.toDouble(),
      riskCategory: data['riskCategory'],
      aiRecommendations: data['aiRecommendations'] != null
          ? List<String>.from(data['aiRecommendations'])
          : null,
      featureImportance: data['featureImportance'] != null
          ? Map<String, double>.from(
              (data['featureImportance'] as Map).map(
                (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
              ),
            )
          : null,
      clinicalNotes: data['clinicalNotes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'implantId': implantId,
      'patientId': patientId,
      'doctorId': doctorId,
      'assessmentDate': Timestamp.fromDate(assessmentDate),
      'probingDepths': probingDepths.toMap(),
      'boneLevelChange': boneLevelChange,
      'marginalBoneLevel': marginalBoneLevel,
      'bleedingOnProbing': bleedingOnProbing.name,
      'suppuration': suppuration.name,
      'mobility': mobility.name,
      'plaqueScore': plaqueScore,
      'modifiedPlaqueIndex': modifiedPlaqueIndex,
      'mucositisPresent': mucositisPresent,
      'periImplantitisDetected': periImplantitisDetected,
      'crestalBoneLevel': crestalBoneLevel,
      'radiographicBoneLoss': radiographicBoneLoss,
      'xrayImageUrl': xrayImageUrl,
      'patientReportedPain': patientReportedPain,
      'patientReportedSwelling': patientReportedSwelling,
      'patientReportedLooseness': patientReportedLooseness,
      'painScore': painScore,
      'predictedRiskScore': predictedRiskScore,
      'riskCategory': riskCategory,
      'aiRecommendations': aiRecommendations,
      'featureImportance': featureImportance,
      'clinicalNotes': clinicalNotes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
