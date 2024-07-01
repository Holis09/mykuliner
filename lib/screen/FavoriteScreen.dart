import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorit screen'),
        ),
        body: const Center(
          child: Text('Tidak ada pengguna yang terautentikasi'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit screen'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('userFavorites')
            .doc(userId)
            .collection('favorites')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Terjadi kesalahan');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var docIds = snapshot.data!.docs.map((doc) => doc.id).toList();
          if (docIds.isEmpty) {
            return const Text('Tidak ada favorit');
          }
          return StreamBuilder(
            stream: _firestore
                .collection('posts')
                .where(FieldPath.documentId, whereIn: docIds)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Terjadi kesalahan');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>? ?? {};
                  String imageUrl =
                      data['imageUrls'] != null && data['imageUrls'].isNotEmpty
                          ? data['imageUrls'][0]
                          : 'URL_default';
                  String nama = data['nama'] ?? 'Nama tidak tersedia';
                  String description =
                      data['description'] ?? 'Deskripsi tidak tersedia';
                  return ListTile(
                    leading: Image.network(imageUrl, width: 100, height: 100,
                        errorBuilder: (context, error, stackTrace) {
                      return const Image(
                        image: AssetImage('assets/images/default.png'),
                        width: 100,
                        height: 100,
                      );
                    }),
                    title: Text(nama),
                    subtitle: Text(description),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await _firestore
                            .collection('userFavorites')
                            .doc(userId)
                            .collection('favorites')
                            .doc(document.id)
                            .delete();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
