import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  void _updateProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(_displayNameController.text);
      await user.updateEmail(_emailController.text);
      // Update phone number and other profile details as needed.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // Asumsi Anda memiliki route login
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan pengguna yang saat ini login
    User? user = FirebaseAuth.instance.currentUser;

    // Akses username
    String? username = user?.displayName;

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Username: ${username ?? "Tidak diketahui"}'),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: 'Display Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Warna merah untuk tombol logout
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
