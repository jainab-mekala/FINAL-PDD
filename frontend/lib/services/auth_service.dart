import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  String get fullName => '$firstName $lastName';

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ============= OTP SYSTEM =============

  Future<void> sendOtp(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // In a real system, you would call an email API here (SendGrid, Twilio, etc.)
    // For demonstration, use code '123456'
    debugPrint('OTP sent to $email: 123456');
  }

  Future<bool> verifyOtp(String email, String otp) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // Any logic here (e.g. check against Redis/Firestore)
    return otp == '123456';
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register new user account
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Create user profile in Firestore
      final profile = UserProfile(
        uid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .set(profile.toMap());
    }

    return credential.user;
  }

  /// Update user profile
  Future<void> updateProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).update(profile.toMap());
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Change password (requires recent login)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    // Re-authenticate user
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

}
