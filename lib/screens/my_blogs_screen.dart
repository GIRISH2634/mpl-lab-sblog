import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding
import 'create_blog_screen.dart';

class MyBlogsScreen extends StatefulWidget {
  const MyBlogsScreen({super.key});

  @override
  _MyBlogsScreenState createState() => _MyBlogsScreenState();
}

class _MyBlogsScreenState extends State<MyBlogsScreen> {
  List<Map<String, String>> myBlogs = [];

  @override
  void initState() {
    super.initState();
    _loadBlogs(); // Load blogs from local storage
  }

  // Load blogs from SharedPreferences
  Future<void> _loadBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedBlogs = prefs.getString('myBlogs');

    if (storedBlogs != null) {
      setState(() {
        myBlogs = List<Map<String, String>>.from(
          jsonDecode(storedBlogs).map((item) => Map<String, String>.from(item)),
        );
      });
    }
  }

  // Save blogs to SharedPreferences
  Future<void> _saveBlogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('myBlogs', jsonEncode(myBlogs));
  }

  // Add a new blog and save it
  void addBlog(String title, String description) {
    setState(() {
      myBlogs.add({'title': title, 'description': description});
    });
    _saveBlogs(); // Save updated blogs list
  }

  // Delete a blog and update storage
  void deleteBlog(int index) {
    setState(() {
      myBlogs.removeAt(index);
    });
    _saveBlogs(); // Save updated blogs list
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
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  myBlogs[index]['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  myBlogs[index]['description']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBlogScreen()),
          );

          if (result != null) {
            addBlog(result['title'], result['description']);
          }
        },
      ),
    );
  }
}
