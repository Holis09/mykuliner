import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  final String userId; // ID pengguna untuk query data

  const ProfilScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: users.doc(userId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text("Terjadi kesalahan: ${snapshot.error}");
            }

            if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Nama: ${data['nama']}",
                        style: TextStyle(fontSize: 20)),
                    Text("Email: ${data['email']}",
                        style: TextStyle(fontSize: 20)),
                    // Tambahkan lebih banyak field sesuai kebutuhan
                  ],
                ),
              );
            } else {
              return Text("Data tidak ditemukan.");
            }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
