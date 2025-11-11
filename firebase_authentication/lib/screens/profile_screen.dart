import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();
  String? _message;

  Future<void> _changePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.length < 6) {
      setState(() => _message = 'Password must be at least 6 characters.');
      return;
    }
    final result = await _authService.changePassword(newPassword);
    setState(() {
      _message = result ?? 'Password changed successfully.';
    });
    _passwordController.clear();
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.getUserEmail() ?? 'No user logged in';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Welcome, $email',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _changePassword, child: const Text('Change Password')),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _message!,
                  style: TextStyle(color: _message!.contains('success') ? Colors.green : Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
