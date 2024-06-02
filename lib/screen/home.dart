import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Added this line to import the intl package
import 'package:mykuliner/screen/add_pos.dart';
import 'package:mykuliner/screen/login_page.dart';
import 'package:url_launcher/url_launcher.dart'; //his line to import the url_launcher package

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Logika untuk kembali ke halaman Home, jika diperlukan
            },
          ),
          IconButton(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Terjadi kesalahan: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada data produk.'));
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                // Periksa apakah 'waktu' ada dan bukan null
                Timestamp? timestamp = data['waktu'] as Timestamp?;
                String formattedDate = 'Tanggal tidak tersedia';
                if (timestamp != null) {
                  DateTime dateTime =
                      timestamp.toDate(); // Konversi ke DateTime
                  formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                      .format(dateTime); // Format DateTime ke String
                }

                String? images = data[
                    'images']; // Pastikan Anda memiliki field imagePath di dokumen Firestore Anda

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (images != null)
                        ImageFromFirebaseStorage(images: images)
                      else
                        const Text(
                            'Tidak ada gambar'), // Placeholder jika imagePath null
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: <Widget>[
                            LikeButton(), // Tombol like
                            IconButton(
                              icon: Icon(Icons.map),
                              onPressed: () {
                                // Logika untuk membuka Google Maps
                                launchURL(
                                    'https://www.google.com/maps/search/?api=1&query=latitude,longitude');
                              },
                            ),
                          ],
                        ),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        // Tambahkan logika untuk mengganti tab atau halaman saat item diklik
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );// Ganti halaman berdasarkan index
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FavoriteScreen()),
              );
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Profil()),
              );
          }
          // Ganti halaman berdasarkan index
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
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

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class ImageFromFirebaseStorage extends StatelessWidget {
  final String? images;

  const ImageFromFirebaseStorage({super.key, this.images});

  Future<String> _getImageUrl() async {
    if (images == null) {
      // Kembalikan URL gambar default jika imagePath adalah null
      return 'https://example.com/default_image.png'; // Ganti dengan URL gambar default Anda
    }
    try {
      String imageUrl =
          await FirebaseStorage.instance.ref(images).getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error loading image: $e');
      return 'https://example.com/default_image.png'; // Kembalikan URL gambar default jika terjadi kesalahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getImageUrl(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Image.network(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
