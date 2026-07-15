import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  AuthService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _authInstance = auth,
        _firestoreInstance = firestore;

  final fb.FirebaseAuth? _authInstance;
  final FirebaseFirestore? _firestoreInstance;

  fb.FirebaseAuth get _auth => _authInstance ?? fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  Future<bool> login(String email, String password) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      // Authenticate with Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String phone,
    String address,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Create user in Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: cleanPassword,
    );

    final uid = credential.user?.uid;
    if (uid != null) {
      // Send email verification
      await credential.user?.sendEmailVerification();

      // 2. Save additional profile fields to Firestore users collection
      await _firestore.collection('users').doc(uid).set({
        'name': name.trim(),
        'email': cleanEmail,
        'phone': phone.trim(),
        'address': address.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    // Sign out immediately to prevent auto-login before verification
    await _auth.signOut();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkLogin() async {
    return _auth.currentUser != null;
  }
  
  Future<Map<String, String>> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'name': 'Khách hàng',
        'email': '',
        'phone': '',
        'address': '',
      };
    }

    try {
      // Fetch user profile from Cloud Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return {
          'name': data['name']?.toString() ?? 'Khách hàng',
          'email': data['email']?.toString() ?? user.email ?? '',
          'phone': data['phone']?.toString() ?? '',
          'address': data['address']?.toString() ?? '',
          'avatarUrl': data['avatarUrl']?.toString() ?? '',
        };
      }
    } catch (_) {
      // Fallback if firestore read fails (e.g. offline or permission issue)
    }

    return {
      'name': 'Khách hàng',
      'email': user.email ?? '',
      'phone': '',
      'address': '',
      'avatarUrl': '',
    };
  }

  Future<bool> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    String? avatarUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
        'address': address,
        'email': user.email ?? '',
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }
}
