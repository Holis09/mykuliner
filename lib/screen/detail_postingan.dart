import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final String description;
  final String postName; // Tambahkan variabel untuk nama postingan
  final String postTime; // Tambahkan variabel untuk waktu postingan
  final String lokasi; // Tambahkan parameter ini

  const DetailScreen(
      {super.key,
      required this.imageUrl,
      required this.description,
      required this.postName,
      required this.postTime,
      required this.lokasi}); // Tambahkan parameter ini

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Gambar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold)), // Nama postingan
                  Text(postTime,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey)), // Waktu postingan
                  Text(lokasi), // Tampilkan lokasi di sini
                  SizedBox(
                      height:
                          8), // Jarak antara nama/waktu postingan dan deskripsi
                  Text(description),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Tambahkan Komentar',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      final comment = commentController.text;
                      final username = "nama_pengguna";
                      final imageName = "nama_gambar";
                      final lokasi = "lokasi_gambar";
                      if (comment.isNotEmpty) {
                        FirebaseFirestore.instance.collection('comments').add({
                          'imageUrl': imageUrl,
                          'comment': comment,
                          'username': username, // Menambahkan username
                          'imageName': imageName, // Menambahkan nama gambar
                          'lokasi': lokasi, // Menambahkan lokasi gambar
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        commentController.clear();
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Add some space before the comments list
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('imageUrl', isEqualTo: imageUrl)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada komentar.'),
                  );
                }
                return ListView(
                  shrinkWrap: true, // Add this line
                  physics: NeverScrollableScrollPhysics(), // Add this line
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String comment = data['comment'] ?? 'No comment provided';
                    String username = data['username'] ?? 'Anonymous';
                    String timestamp = data['timestamp'] != null
                        ? data['timestamp'].toDate().toString()
                        : 'No timestamp';
                    return ListTile(
                      title: Text(comment),
                      subtitle: Text(username),
                      trailing: Text(timestamp),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPostingan extends StatelessWidget {
  final List<String> imageUrls;

  const DetailPostingan({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Postingan'),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
