import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mykuliner/screen/FavoriteScreen.dart';
import 'package:mykuliner/screen/add_pos.dart';
import 'package:mykuliner/screen/detail_postingan.dart';
import 'package:mykuliner/screen/login_page.dart';
import 'package:mykuliner/screen/profil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Set<String> favoritedPosts = Set<String>();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = ""; // Menambahkan variabel untuk query pencarian

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddPostScreen(image: _image),
        ),
      );
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> deletePost(String docId) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('posts').doc(docId);

      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        String? imagePath = data['imageUrls'];

        if (imagePath != null) {
          await FirebaseStorage.instance.ref(imagePath).delete();
          print("Gambar berhasil dihapus dari Storage");
        }

        await docRef.delete();
        print("Postingan berhasil dihapus dari Firestore");
      }
    } catch (e) {
      print("Error saat menghapus postingan dan gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menyembunyikan tanda panah kembali
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Cari postingan...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery =
                  value.trim().toLowerCase(); // Contoh konversi ke lowercase
              print("Search Query: $_searchQuery");
            });
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Logika pencarian bisa ditambahkan di sini jika diperlukan
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _searchQuery.isEmpty
            ? FirebaseFirestore.instance.collection('posts').snapshots()
            : FirebaseFirestore.instance
                .collection('posts')
                .where('title', isGreaterThanOrEqualTo: _searchQuery)
                .where('title', isLessThanOrEqualTo: _searchQuery + '\uf8ff')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Text('Terjadi kesalahan: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          print("Found ${snapshot.data!.docs.length} docs");
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada produk yang cocok.'));
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                print("Document data: $data"); // Debugging statement
                Timestamp? timestamp = data['waktu'] as Timestamp?;
                String formattedDate = 'Tanggal tidak tersedia';
                if (timestamp != null) {
                  DateTime dateTime = timestamp.toDate();
                  formattedDate =
                      DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
                }

                List<dynamic>? images = data[
                    'imageUrls']; // Pastikan Anda memiliki field imageUrl di dokumen Firestore Anda
                print(
                    "URL Gambar: ${data['imageUrls']}"); // Added this line to print the image URL

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (images != null && images.isNotEmpty)
                        ImageFromFirebaseStorage(images: images.cast<String>())
                      else
                        const Text('Tidak ada gambar'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(data['nama'] ?? 'Nama tidak tersedia',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                            data['description'] ?? 'Deskripsi tidak tersedia'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text(formattedDate,
                            style: TextStyle(color: Colors.grey)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LikeButton(), // Tombol like
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deletePost(document.id),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tulis komentar...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                // Tambahkan logika untuk mengirim komentar
                              },
                            ),
                          ],
                        ),
                      ),
                      // Baris kode yang ditambahka
                    ],
                  ),
                );
              }).toList(),
            );
          }
          return const Center(child: Text('Memuat data...'));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ); // Ganti halaman berdasarkan index
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AddPostScreen()),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoriteScreen(),
                ),
              );
              break;
            case 3:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
              break;
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        child: const Icon(Icons.camera_alt),
        backgroundColor:
            Colors.white, // Ubah warna latar belakang menjadi putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side:
              BorderSide(color: Colors.black, width: 1), // Tambahkan border 5px
        ),
      ),
    );
  }
}

class ImageFromFirebaseStorage extends StatelessWidget {
  final List<String>? images;

  const ImageFromFirebaseStorage({super.key, this.images});

  @override
  Widget build(BuildContext context) {
    if (images == null || images!.isEmpty) {
      return const Text('Tidak ada gambar');
    }

    return Container(
      height: 200.0,
      child: PageView.builder(
        itemCount: images?.length ?? 0,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPostingan(
                        imageUrls: images ?? ['default_image_url'])),
              );
            },
            child: Image.network(
              images?[index] ?? 'default_image_url',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          );
        },
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
      color: isLiked ? Colors.red : null, // Ubah warna jika disukai
      onPressed: () {
        setState(() {
          isLiked = !isLiked; // Toggle state liked
        });
      },
    );
  }
}
