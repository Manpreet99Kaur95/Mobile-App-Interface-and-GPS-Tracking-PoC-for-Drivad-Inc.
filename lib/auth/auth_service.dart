// lib/auth/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  /// ==============================
  /// BASIC GETTERS
  /// ==============================

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ==============================
  /// LOGIN
  /// ==============================

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// ==============================
  /// REGISTER + SAVE ROLE
  /// ==============================

  Future<UserCredential> register({
    required String email,
    required String password,
    required String role, // driver / advertiser / vendor
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    await _db.collection('users').doc(uid).set({
      'email': email.trim(),
      'role': role.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  /// ==============================
  /// ROLE STREAM (RECOMMENDED)
  ///

  Stream<String> userRoleStream(String uid) {
    final ref = _db.collection('users').doc(uid);

    return ref.snapshots().asyncMap((doc) async {
      if (doc.exists) {
        final data = doc.data();
        final role = (data?['role'] as String?)?.trim().toLowerCase();

        if (role != null && role.isNotEmpty) {
          return role;
        }
      }

      // If doc missing or role missing -> create default driver
      final email = _auth.currentUser?.email?.trim();

      await ref.set({
        'email': email,
        'role': 'driver',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return 'driver';
    });
  }

  /// ==============================
  /// ONE-TIME ROLE FETCH (IF YOU STILL USE FUTURE)
  /// ==============================

  Future<String> getOrCreateUserRole(String uid) async {
    final ref = _db.collection('users').doc(uid);

    final doc = await ref.get(const GetOptions(source: Source.serverAndCache));

    if (doc.exists) {
      final data = doc.data();
      final role = (data?['role'] as String?)?.trim().toLowerCase();

      if (role != null && role.isNotEmpty) {
        return role;
      }

      await ref.set({
        'role': 'driver',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return 'driver';
    }

    final email = _auth.currentUser?.email?.trim();

    await ref.set({
      'email': email,
      'role': 'driver',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return 'driver';
  }

  /// ==============================
  /// LOGOUT
  /// ==============================

  Future<void> logout() async {
    await _auth.signOut();
  }
}
