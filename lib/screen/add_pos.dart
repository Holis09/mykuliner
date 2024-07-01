import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  final File? image;

  const AddPostScreen({super.key, this.image});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _descriptionController = TextEditingController();
  final _namaController = TextEditingController();
  final _locationController =
      TextEditingController(); // Tambahkan controller untuk lokasi
  List<XFile> _pickedFiles = []; // Inisialisasi sebagai list kosong
  List<String> _imageUrlList = [];
  static const int maxImages = 5; // Batas maksimal foto

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    if (_pickedFiles.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Anda hanya bisa mengunggah maksimal $maxImages foto')),
      );
      return;
    }

    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        if (_pickedFiles.length >= maxImages) break;

        final ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child(DateTime.now().toString() + '.jpg');

        await ref.putFile(File(file.path));
        final imageUrl = await ref.getDownloadURL();
        _imageUrlList.add(imageUrl);
        _pickedFiles.add(file);
      }

      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (_pickedFiles.length >= maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Anda hanya bisa mengunggah maksimal $maxImages foto')),
      );
      return;
    }

    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('images')
          .child(DateTime.now().toString() + '.jpg');

      await ref.putFile(File(pickedFile.path));
      final imageUrl = await ref.getDownloadURL();
      _imageUrlList.add(imageUrl);
      _pickedFiles.add(pickedFile);

      setState(() {});
    }
  }

  Widget _buildImage() {
    if (_pickedFiles.isNotEmpty) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pickedFiles.length,
        itemBuilder: (context, index) {
          return Image.file(File(_pickedFiles[index].path));
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image != null) Image.file(widget.image!),
              GestureDetector(
                onTap: _pickImage,
                onLongPress: _takePicture,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  child: _buildImage(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 1,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Lokasi'),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_imageUrlList.isNotEmpty &&
                        _descriptionController.text.isNotEmpty &&
                        _namaController.text.isNotEmpty &&
                        _locationController.text.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .add({
                            'imageUrls': _imageUrlList,
                            'description': _descriptionController.text,
                            'nama': _namaController.text,
                            'lokasi': _locationController.text,
                            'waktu': DateTime.now(),
                          })
                          .then((value) => print("Post added"))
                          .catchError(
                              (error) => print("Failed to add post: $error"));
                      Navigator.pop(context);
                    } else {
                      if (_imageUrlList.isEmpty)
                        print("Image URL list is empty");
                      if (_descriptionController.text.isEmpty)
                        print("Description is empty");
                      if (_namaController.text.isEmpty) print("Name is empty");
                      if (_locationController.text.isEmpty)
                        print("Location is empty");
                    }
                  },
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
