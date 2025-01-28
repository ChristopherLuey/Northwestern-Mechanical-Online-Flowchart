import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flowchart_viewer.dart';
import 'curriculum_planner.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';
import 'course_box.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  final settingsController = SettingsController(SettingsService());
  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({Key? key, required this.settingsController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurriculumProvider()),
        ChangeNotifierProvider(create: (_) => settingsController),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Curriculum Planner',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google user credentials
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('User signed in: ${FirebaseAuth.instance.currentUser?.displayName}');
    } catch (error) {
      print('Sign in failed: $error');
    }
  }

  void _showSettingsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sign Out Button
            Consumer<SettingsController>(
              builder: (context, settings, _) => ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                enabled: FirebaseAuth.instance.currentUser != null,
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  settings.notifyListeners();
                  Navigator.of(context).pop();
                },
              ),
            ),
            // Prereq Warning Toggle
            Consumer<SettingsController>(
              builder: (context, settings, _) => SwitchListTile(
                title: const Text('Show Prerequisite Warnings'),
                value: settings.showPrereqWarnings,
                onChanged: (value) => settings.togglePrereqWarnings(value),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                'Version: 1.0.0',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                'Created by Christopher Luey (ME \'25)',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        elevation: 20.0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mechanical Engineering Flowchart',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Keep the settings button always visible
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsPopup(context),
          ),
          // Profile/sign-in button
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user != null) {
                return GestureDetector(
                  onTap: () => _showSettingsPopup(context),
                  child: CircleAvatar(
                    backgroundImage: user.photoURL != null 
                        ? NetworkImage(user.photoURL!)
                        : null,
                    radius: 16,
                  ),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () => _handleSignIn(),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: const FlowchartViewer(),
    );
  }
}
