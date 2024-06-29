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
  List<XFile>? _pickedFiles;
  List<String> _imageUrlList = [];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child(DateTime.now().toString() + '.jpg');

        await ref.putFile(File(file.path));
        final imageUrl = await ref.getDownloadURL();
        _imageUrlList.add(imageUrl);
      }

      setState(() {
        _pickedFiles = pickedFiles;
      });
    }
  }

  Widget _buildImage() {
    if (_pickedFiles != null && _pickedFiles!.isNotEmpty) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pickedFiles!.length,
        itemBuilder: (context, index) {
          return Image.file(File(_pickedFiles![index].path));
        },
      );
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
                if (_imageUrlList.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _namaController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('posts').add({
                    'imageUrls': _imageUrlList,
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
