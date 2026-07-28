import 'package:cloud_firestore/cloud_firestore.dart';

enum Gender { male, female, other }

enum SmokingStatus { nonSmoker, formerSmoker, currentSmoker }

class Patient {
  final String id;
  final String doctorId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String? email;
  final String? phone;
  final SmokingStatus smokingStatus;
  final List<String> medicalConditions; // diabetes, osteoporosis, etc.
  final List<String> medications;
  final double? bmi;
  final bool hasPeriodontalHistory;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> implantIds;

  Patient({
    required this.id,
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.email,
    this.phone,
    required this.smokingStatus,
    required this.medicalConditions,
    required this.medications,
    this.bmi,
    required this.hasPeriodontalHistory,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.implantIds,
  });

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: Gender.values.firstWhere(
        (e) => e.name == data['gender'],
        orElse: () => Gender.other,
      ),
      email: data['email'],
      phone: data['phone'],
      smokingStatus: SmokingStatus.values.firstWhere(
        (e) => e.name == data['smokingStatus'],
        orElse: () => SmokingStatus.nonSmoker,
      ),
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      bmi: data['bmi']?.toDouble(),
      hasPeriodontalHistory: data['hasPeriodontalHistory'] ?? false,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      implantIds: List<String>.from(data['implantIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender.name,
      'email': email,
      'phone': phone,
      'smokingStatus': smokingStatus.name,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'bmi': bmi,
      'hasPeriodontalHistory': hasPeriodontalHistory,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'implantIds': implantIds,
    };
  }

  Patient copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    SmokingStatus? smokingStatus,
    List<String>? medicalConditions,
    List<String>? medications,
    double? bmi,
    bool? hasPeriodontalHistory,
    String? notes,
    List<String>? implantIds,
  }) {
    return Patient(
      id: id,
      doctorId: doctorId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      bmi: bmi ?? this.bmi,
      hasPeriodontalHistory: hasPeriodontalHistory ?? this.hasPeriodontalHistory,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      implantIds: implantIds ?? this.implantIds,
    );
  }
}
