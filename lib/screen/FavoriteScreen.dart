import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text('Silakan login untuk melihat favorit.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Tidak ada data favorit.'));
          }

          List<String> favoritePosts =
              List<String>.from(snapshot.data!['favorites'] ?? []);

          if (favoritePosts.isEmpty) {
            return Center(child: Text('Belum ada post favorit.'));
          }

          return ListView.builder(
            itemCount: favoritePosts.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(favoritePosts[index])
                    .get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.hasError || !postSnapshot.hasData) {
                    return Container(); // Handle error or loading state
                  }

                  Map<String, dynamic> postData =
                      postSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(postData['nama'] ?? 'Nama tidak tersedia'),
                    subtitle: Text(
                        postData['description'] ?? 'Deskripsi tidak tersedia'),
                    // You can add more UI elements to display details of the favorite post
                    // Navigate to post detail screen or perform other actions here
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
