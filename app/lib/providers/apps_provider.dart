import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_model.dart';

class AppsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppModel> _apps = [];
  bool _isLoading = false;
  String? _error;

  List<AppModel> get apps => _apps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchApps() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('[AppsProvider] No user logged in');
        _apps = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      print('[AppsProvider] Fetching apps for user: $uid');

      // Fetch public apps and user's own apps
      final publicQuery = await _firestore
          .collection('apps')
          .where('isPublic', isEqualTo: true)
          .get();

      final ownQuery = await _firestore
          .collection('apps')
          .where('ownerId', isEqualTo: uid)
          .get();

      final allDocs = <String, DocumentSnapshot>{};
      for (final doc in publicQuery.docs) {
        allDocs[doc.id] = doc;
      }
      for (final doc in ownQuery.docs) {
        allDocs[doc.id] = doc;
      }

      _apps = allDocs.values.map((doc) => AppModel.fromFirestore(doc)).toList();
      _apps.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));

      print('[AppsProvider] Fetched ${_apps.length} apps');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('[AppsProvider] Error fetching apps: $e');
      _error = 'Failed to load apps';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppModel?> createApp({
    required String name,
    String description = '',
    String icon = '📋',
    bool isPublic = false,
    String webhookUrl = '',
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _error = 'You must be logged in to create an app';
        notifyListeners();
        return null;
      }

      print('[AppsProvider] Creating app: $name');

      final docRef = await _firestore.collection('apps').add({
        'name': name,
        'description': description,
        'icon': icon,
        'imageUrl': '',
        'coverColor': '',
        'ownerId': uid,
        'isPublic': isPublic,
        'responseType': 'yes_no',
        'webhookUrl': webhookUrl,
        'subscriberCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      final newApp = AppModel.fromFirestore(doc);
      _apps.insert(0, newApp);

      print('[AppsProvider] App created: ${docRef.id}');
      notifyListeners();
      return newApp;
    } catch (e) {
      print('[AppsProvider] Error creating app: $e');
      _error = 'Failed to create app';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
