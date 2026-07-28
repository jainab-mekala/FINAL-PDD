import 'package:cloud_firestore/cloud_firestore.dart';

enum ImplantStatus { healthy, watchlist, atRisk, critical, failed }

enum ImplantLocation {
  upperLeft,
  upperRight,
  lowerLeft,
  lowerRight,
}

class ImplantPosition {
  final String arch; // 'upper' or 'lower'
  final String side; // 'left' or 'right'
  final int toothNumber; // FDI notation: 11-48

  ImplantPosition({
    required this.arch,
    required this.side,
    required this.toothNumber,
  });

  factory ImplantPosition.fromMap(Map<String, dynamic> map) {
    return ImplantPosition(
      arch: map['arch'] ?? 'upper',
      side: map['side'] ?? 'left',
      toothNumber: map['toothNumber'] ?? 11,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'arch': arch,
      'side': side,
      'toothNumber': toothNumber,
    };
  }

  String get label => 'Tooth #$toothNumber';
}

class Implant {
  final String id;
  final String patientId;
  final String doctorId;
  final String brand;
  final String model;
  final double diameter; // mm
  final double length; // mm
  final ImplantPosition position;
  final DateTime placementDate;
  final DateTime? loadingDate;
  final String? boneGraftType;
  final bool hadComplicationsAtPlacement;
  final String? complicationNotes;
  final ImplantStatus currentStatus;
  final double riskScore; // 0.0 - 1.0
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> assessmentIds;

  Implant({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.brand,
    required this.model,
    required this.diameter,
    required this.length,
    required this.position,
    required this.placementDate,
    this.loadingDate,
    this.boneGraftType,
    required this.hadComplicationsAtPlacement,
    this.complicationNotes,
    required this.currentStatus,
    required this.riskScore,
    required this.createdAt,
    required this.updatedAt,
    required this.assessmentIds,
  });

  String get statusLabel {
    switch (currentStatus) {
      case ImplantStatus.healthy:
        return 'Healthy';
      case ImplantStatus.watchlist:
        return 'Watch List';
      case ImplantStatus.atRisk:
        return 'At Risk';
      case ImplantStatus.critical:
        return 'Critical';
      case ImplantStatus.failed:
        return 'Failed';
    }
  }

  int get monthsSincePlacement {
    final now = DateTime.now();
    return (now.difference(placementDate).inDays / 30).floor();
  }

  factory Implant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Implant(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      diameter: (data['diameter'] ?? 3.5).toDouble(),
      length: (data['length'] ?? 10.0).toDouble(),
      position: ImplantPosition.fromMap(data['position'] ?? {}),
      placementDate: (data['placementDate'] as Timestamp).toDate(),
      loadingDate: data['loadingDate'] != null
          ? (data['loadingDate'] as Timestamp).toDate()
          : null,
      boneGraftType: data['boneGraftType'],
      hadComplicationsAtPlacement: data['hadComplicationsAtPlacement'] ?? false,
      complicationNotes: data['complicationNotes'],
      currentStatus: ImplantStatus.values.firstWhere(
        (e) => e.name == data['currentStatus'],
        orElse: () => ImplantStatus.healthy,
      ),
      riskScore: (data['riskScore'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      assessmentIds: List<String>.from(data['assessmentIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'brand': brand,
      'model': model,
      'diameter': diameter,
      'length': length,
      'position': position.toMap(),
      'placementDate': Timestamp.fromDate(placementDate),
      'loadingDate': loadingDate != null ? Timestamp.fromDate(loadingDate!) : null,
      'boneGraftType': boneGraftType,
      'hadComplicationsAtPlacement': hadComplicationsAtPlacement,
      'complicationNotes': complicationNotes,
      'currentStatus': currentStatus.name,
      'riskScore': riskScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'assessmentIds': assessmentIds,
    };
  }
}
