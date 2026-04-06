import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: JaNeeTheme.amber,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(user?.email ?? 'Not set'),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark ? JaNeeTheme.darkDivider : JaNeeTheme.lightDivider,
                ),
                ListTile(
                  leading: const Icon(Icons.person_outlined),
                  title: const Text('Display Name'),
                  subtitle: Text(user?.displayName ?? 'Not set'),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark ? JaNeeTheme.darkDivider : JaNeeTheme.lightDivider,
                ),
                ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('User ID'),
                  subtitle: Text(
                    user?.uid ?? '',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Appearance section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'APPEARANCE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: JaNeeTheme.amber,
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Theme'),
              subtitle: Text(isDark ? 'Dark mode' : 'Light mode'),
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  // Theme toggle handled at MaterialApp level
                  print('[Settings] Theme toggle tapped. Current: ${isDark ? 'dark' : 'light'}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme preference will be available in a future update'),
                    ),
                  );
                },
              ),
            ),
          ),

          // About section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Text(
              'ABOUT',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: JaNeeTheme.amber,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: isDark ? JaNeeTheme.darkDivider : JaNeeTheme.lightDivider,
                ),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Build'),
                  subtitle: Text('Development'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: isDark
                  ? const Color(0xFF2A1A1A)
                  : const Color(0xFFFFF5F5),
              child: ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        'Sign Out',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().signOut();
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
