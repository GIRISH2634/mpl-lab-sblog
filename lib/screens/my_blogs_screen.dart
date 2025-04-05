import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../models/blog_model.dart';
import 'blog_detail_screen.dart';
import 'create_blog_screen.dart';

class MyBlogsScreen extends StatefulWidget {
  const MyBlogsScreen({super.key});

  @override
  _MyBlogsScreenState createState() => _MyBlogsScreenState();
}

class _MyBlogsScreenState extends State<MyBlogsScreen> {
  List<Map<String, dynamic>> myBlogs = [];

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedBlogs = prefs.getString('myBlogs');

    if (storedBlogs != null) {
      try {
        setState(() {
          myBlogs = List<Map<String, dynamic>>.from(jsonDecode(storedBlogs));
        });
      } catch (e) {
        print('Error decoding blogs: $e');
      }
    }
  }

  Future<void> _saveBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myBlogs', jsonEncode(myBlogs));
  }

  void addBlog(Map<String, dynamic> blogData) {
    setState(() {
      myBlogs.add(blogData);
    });
    _saveBlogs();
  }

  void deleteBlog(int index) {
    setState(() {
      myBlogs.removeAt(index);
    });
    _saveBlogs();
  }

  Future<void> _clearAllBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('myBlogs');
    setState(() {
      myBlogs.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All blogs cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Blogs')),
      body: myBlogs.isEmpty
          ? const Center(
              child: Text(
                'No blogs yet, create one!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: myBlogs.length,
                itemBuilder: (context, index) {
                  final blog = myBlogs[index];

                  // ✅ Safely parse comments
                  List<Comment> parsedComments = [];
                  if (blog['comments'] is List) {
                    try {
                      parsedComments = (blog['comments'] as List)
                          .where((item) => item is Map<String, dynamic>)
                          .map((commentMap) =>
                              Comment.fromMap(commentMap))
                          .toList();
                    } catch (e) {
                      print("Error parsing comments for blog $index: $e");
                    }
                  }

                  // ✅ Safely parse likes
                  List<String> parsedLikes = [];
                  if (blog['likes'] is List) {
                    try {
                      parsedLikes = List<String>.from(blog['likes']);
                    } catch (e) {
                      print("Error parsing likes for blog $index: $e");
                    }
                  }

                  Blog selectedBlog = Blog(
                    id: 'local_$index',
                    title: blog['title'] ?? '',
                    description: blog['description'] ?? '',
                    author: blog['author'] ?? 'Unknown',
                    category: blog['category'] ?? 'General',
                    publishDate: DateTime.tryParse(blog['publishDate'] ?? '') ??
                        DateTime.now(),
                    imageUrl: blog['image'],
                    likes: parsedLikes,
                    comments: parsedComments,
                    content: blog['content'] ?? '',
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BlogDetailScreen(blog: selectedBlog),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (blog['image'] != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Image.file(
                                  File(blog['image']),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.image_not_supported),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    blog['title'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    blog['description'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Author: ${blog['author'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Category: ${blog['category'] ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.blueGrey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteBlog(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_blog',
            child: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateBlogScreen()),
              );

              if (result != null) {
                addBlog(result);
              }
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'clear_blogs',
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete_forever),
            onPressed: _clearAllBlogs,
          ),
        ],
      ),
    );
  }
}
