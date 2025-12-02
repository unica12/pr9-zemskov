import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';
import 'notes_page.dart';

const supabaseUrl = 'https://skuzitxebiqbaqtsnpoo.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNrdXppdHhlYmlxYmFxdHNucG9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NzI0NDcsImV4cCI6MjA4MDI0ODQ0N30.3gB417-rHtotes0Gf3YNMmzSyYMxI-e_V0eC8ue7jdM';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Notes',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthGate(),
        '/notes': (context) => const NotesPage(),
      },
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final authState = snapshot.data!;
            if (authState.event == AuthChangeEvent.signedIn) {
              return const NotesPage();
            }
          }
          return const AuthGate();
        },
      ),
    );
  }
}