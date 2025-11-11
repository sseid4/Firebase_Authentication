import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import '../screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthenticationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final AuthService _authService = AuthService();
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is logged in
          return const ProfileScreen();
        }
        return Scaffold(
          appBar: AppBar(title: Text(showLogin ? 'Sign In' : 'Register')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: showLogin
                ? LoginForm(
                    onToggle: () => setState(() => showLogin = false),
                    authService: _authService,
                  )
                : RegisterForm(
                    onToggle: () => setState(() => showLogin = true),
                    authService: _authService,
                  ),
          ),
        );
      },
    );
  }
}

/// Login Form Widget
class LoginForm extends StatefulWidget {
  final VoidCallback onToggle;
  final AuthService authService;

  const LoginForm({super.key, required this.onToggle, required this.authService});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.authService.signIn(_email.text, _password.text);
      setState(() => _error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter an email';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _signIn, child: const Text('Sign In')),
          TextButton(onPressed: widget.onToggle, child: const Text('Don’t have an account? Register')),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}

/// Register Form Widget
class RegisterForm extends StatefulWidget {
  final VoidCallback onToggle;
  final AuthService authService;

  const RegisterForm({super.key, required this.onToggle, required this.authService});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.authService.register(_email.text, _password.text);
      setState(() => _error = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter an email';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _register, child: const Text('Register')),
          TextButton(onPressed: widget.onToggle, child: const Text('Already have an account? Sign In')),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
