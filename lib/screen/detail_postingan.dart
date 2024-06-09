import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailPostingan extends StatelessWidget {
  final List<String> imageUrls;

  const DetailPostingan({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = {
      'waktu': Timestamp.now(),
    };

    Timestamp? timestamp = data['waktu'] as Timestamp?;
    String formattedDate = 'Tanggal tidak tersedia';
    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Postingan'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: PageView.builder(
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(formattedDate),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    border: OutlineInputBorder(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
