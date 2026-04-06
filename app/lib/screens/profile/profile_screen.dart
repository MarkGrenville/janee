import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _publicProfile = false;
  bool _isLoading = true;
  bool _isSaving = false;

  int _totalDecisions = 0;
  int _yesCount = 0;
  int _noCount = 0;
  int _skipCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      print('[ProfileScreen] Loading profile for: $uid');

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['displayName'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _publicProfile = data['publicProfile'] ?? false;
      } else {
        _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('[ProfileScreen] Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('decisions')
          .get();

      int yes = 0, no = 0, skip = 0;
      for (final doc in snap.docs) {
        final d = doc.data()['decision'];
        if (d == 'yes') {
          yes++;
        } else if (d == 'no') {
          no++;
        } else if (d == 'skip') {
          skip++;
        }
      }

      setState(() {
        _totalDecisions = snap.docs.length;
        _yesCount = yes;
        _noCount = no;
        _skipCount = skip;
      });

      print('[ProfileScreen] Stats: $yes yes, $no no, $skip skip');
    } catch (e) {
      print('[ProfileScreen] Error loading stats: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isSaving = true);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      print('[ProfileScreen] Saving profile');

      await _firestore.collection('users').doc(uid).set({
        'displayName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'publicProfile': _publicProfile,
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
        'photoURL': FirebaseAuth.instance.currentUser?.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_nameController.text.trim());

      print('[ProfileScreen] Profile saved');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      print('[ProfileScreen] Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: JaNeeTheme.amber.withAlpha(51),
                    backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user?.photoURL == null || user!.photoURL!.isEmpty
                        ? Text(
                            (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              color: JaNeeTheme.amber,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? JaNeeTheme.darkCard : JaNeeTheme.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? JaNeeTheme.darkDivider : JaNeeTheme.lightDivider,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Total', _totalDecisions.toString(), JaNeeTheme.amber),
                        _buildStat('Yes', _yesCount.toString(), const Color(0xFF81C784)),
                        _buildStat('No', _noCount.toString(), const Color(0xFFE57373)),
                        _buildStat('Skip', _skipCount.toString(), const Color(0xFFBA68C8)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      prefixIcon: Icon(Icons.edit_note),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: const Text('Public Profile'),
                    subtitle: const Text('Allow others to see your profile'),
                    value: _publicProfile,
                    onChanged: (value) => setState(() => _publicProfile = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
