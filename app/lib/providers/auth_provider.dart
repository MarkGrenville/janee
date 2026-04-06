import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<User?>? _authSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  AuthProvider() {
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    print('[AuthProvider] Auth state changed: ${user?.uid ?? 'signed out'}');
    _user = user;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('[AuthProvider] Signing in with email: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('[AuthProvider] Sign in successful');
    } on FirebaseAuthException catch (e) {
      print('[AuthProvider] Sign in error: ${e.code} - ${e.message}');
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[AuthProvider] Unexpected sign in error: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('[AuthProvider] Registering with email: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(displayName);

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'displayName': displayName,
        'email': email,
        'photoURL': '',
        'publicProfile': false,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('[AuthProvider] Registration successful: ${credential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      print('[AuthProvider] Registration error: ${e.code} - ${e.message}');
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[AuthProvider] Unexpected registration error: $e');
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('[AuthProvider] Starting Google sign in');

      final provider = GoogleAuthProvider();
      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }

      final uid = _auth.currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await _firestore.collection('users').doc(uid).set({
          'displayName': _auth.currentUser!.displayName ?? '',
          'email': _auth.currentUser!.email ?? '',
          'photoURL': _auth.currentUser!.photoURL ?? '',
          'publicProfile': false,
          'bio': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('[AuthProvider] Google sign in successful');
    } catch (e) {
      print('[AuthProvider] Google sign in error: $e');
      _error = 'Google sign in failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      print('[AuthProvider] Signing out');
      await _auth.signOut();
      print('[AuthProvider] Sign out successful');
    } catch (e) {
      print('[AuthProvider] Sign out error: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
