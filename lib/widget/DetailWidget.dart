import 'package:flutter/material.dart';

class PostDetailWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String time;

  const PostDetailWidget({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: <Widget>[
          Image.network(imageUrl),
          Text(description),
          Text(time),
        ],
      ),
    );
  }
}
