import 'package:flutter/material.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, String> blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blog['title']!)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(blog['title']!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Text('By ${blog['author']}', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            Text(blog['description']!, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
