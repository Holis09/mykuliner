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
import 'package:url_launcher/url_launcher.dart';

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

  // Fungsi untuk membuka WhatsApp
  Future<void> _shareToWhatsApp(String message) async {
    final url = Uri.parse('whatsapp://send?text=$message');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        print('Tidak dapat membuka WhatsApp karena aplikasi tidak terinstal');
      }
    } catch (e) {
      print('Terjadi kesalahan saat mencoba membuka WhatsApp: $e');
    }
  }

  void toggleLike(String docId, String userId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('posts').doc(docId);
    DocumentReference likeRef = docRef.collection('userLikes').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot likeSnapshot = await transaction.get(likeRef);
      DocumentSnapshot postSnapshot = await transaction.get(docRef);

      if (!postSnapshot.exists) {
        throw Exception("Postingan tidak ditemukan!");
      }

      Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>;
      int newLikes = postData['likes'] ?? 0;

      if (likeSnapshot.exists) {
        // Jika like sudah ada, hapus like
        newLikes -= 1;
        transaction.delete(likeRef);
      } else {
        // Jika like belum ada, tambahkan like
        newLikes += 1;
        transaction.set(likeRef, {'liked': true});
      }
      transaction.update(docRef, {'likes': newLikes});
    });
  }

  Future<void> saveToFavorites(String docId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userId)
        .collection('favorites')
        .doc(docId)
        .set({'timestamp': FieldValue.serverTimestamp()});
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

                List<dynamic>? images = data['imageUrls'];
                String docId = document.id;
                int likes = data['likes'] ?? 0;
                bool isLiked = favoritedPosts.contains(docId);

                return _buildPost(
                  username: data['nama'] ?? 'Nama tidak tersedia',
                  imageUrls: images ?? [],
                  likes: likes,
                  isLiked: isLiked,
                  description:
                      data['description'] ?? 'Deskripsi tidak tersedia',
                  docId: docId,
                  formattedDate: formattedDate,
                  data: data, // Added data parameter
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
              );
              break;
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

  Widget _buildPost({
    required String username,
    required List<dynamic> imageUrls,
    required int likes,
    required bool isLiked,
    required String description,
    required String docId,
    required String formattedDate,
    required Map<String, dynamic> data, // Added data parameter
  }) {
    print("Username received: $username"); // Debugging statement
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  imageUrls.isNotEmpty ? imageUrls[0] : 'default_image_url'),
            ),
            title: Text(username), // Menampilkan nama pengguna
            trailing: PopupMenuButton<String>(
              onSelected: (String value) async {
                if (value == 'save') {
                  saveToFavorites(docId);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'save',
                    child: Text('Simpan'),
                  ),
                ];
              },
            ),
          ),
          Container(
            height: 200,
            child: PageView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => DetailScreen(
                          imageUrl: imageUrls[index],
                          postName: data['nama'] ?? 'Nama tidak tersedia',
                          lokasi: data['lokasi'] ?? 'Lokasi tidak tersedia',
                          description: description,
                          postTime: formattedDate),
                    ));
                  },
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Text('Gagal memuat gambar');
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(docId)
                      .collection('userLikes')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isLiked = snapshot.data?.data() != null;
                    return IconButton(
                      icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border),
                      color: isLiked ? Colors.red : null,
                      onPressed: () {
                        toggleLike(docId,
                            FirebaseAuth.instance.currentUser?.uid ?? '');
                      },
                    );
                  },
                ),
                Text('$likes'),
                const SizedBox(width: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(docId)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    }
                    int commentsCount = snapshot.data?.docs.length ?? 0;
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                    imageUrl: imageUrls.isNotEmpty
                                        ? imageUrls[0]
                                        : 'default_image_url',
                                    postName:
                                        data['nama'] ?? 'Nama tidak tersedia',
                                    lokasi: data['lokasi'] ??
                                        'Lokasi tidak tersedia',
                                    description: description,
                                    postTime:
                                        formattedDate), // Tambahkan parameter postTime di sini
                              ),
                            );
                          },
                        ),
                        Text(commentsCount > 0
                            ? '$commentsCount'
                            : ''), // Menampilkan jumlah komentar atau string kosong
                      ],
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _shareToWhatsApp('Check out this post: $description');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Ubah alignment menjadi start
              children: [
                Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(formattedDate), // Tambahkan tanggal di sini
                Text(data['lokasi'] ??
                    'Lokasi tidak tersedia'), // Tambahkan lokasi di sini
                Text(description),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

Future<void> signInAnonymously() async {
  try {
    await FirebaseAuth.instance.signInAnonymously();
    print("Signed in with temporary account.");
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case "operation-not-allowed":
        print("Anonymous auth hasn't been enabled for this project.");
        break;
      default:
        print("Unknown error.");
    }
  }
}
