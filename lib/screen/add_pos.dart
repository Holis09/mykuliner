import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descriptionController = TextEditingController();
  final _namaController =
      TextEditingController(); // Added this line to define _namaController
  XFile? _pickedFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(DateTime.now().toString() + '.jpg');

      await ref.putFile(File(pickedFile.path));
      _imageUrl = await ref.getDownloadURL();

      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Widget _buildImage() {
    if (_pickedFile != null) {
      return Image.file(File(_pickedFile!.path));
    } else {
      return Center(child: Text('Tap to add image'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Post')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: _buildImage(),
              ),
            ),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'nama'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_imageUrl != null &&
                    _descriptionController.text.isNotEmpty &&
                    _namaController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('posts').add({
                    'imageUrl': _imageUrl,
                    'description': _descriptionController.text,
                    'nama': _namaController.text,
                    'waktu': DateTime.now(),
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
