import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blog_model.dart';
import 'package:intl/intl.dart';

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final String currentUserId = 'currentUser'; // Replace with actual user ID
  late Blog _currentBlog;

  @override
  void initState() {
    super.initState();
    _currentBlog = widget.blog;
  }

  Future<void> _toggleLike() async {
    setState(() {
      if (_currentBlog.likes.contains(currentUserId)) {
        _currentBlog.likes.remove(currentUserId);
      } else {
        _currentBlog.likes.add(currentUserId);
      }
    });

    await _updateLocalStorage();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      userId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentBlog.comments.insert(0, newComment);
    });

    _commentController.clear();
    await _updateLocalStorage();
  }

  Future<void> _updateLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBlogs = prefs.getString('myBlogs');

    if (storedBlogs != null) {
      List<dynamic> blogs = jsonDecode(storedBlogs);

      final index = blogs.indexWhere((blog) => blog['id'] == _currentBlog.id);

      if (index != -1) {
        // Update the blog data in the list
        blogs[index] = _currentBlog.toMap();

        // Save back to SharedPreferences
        await prefs.setString('myBlogs', jsonEncode(blogs));
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildBlogImage() {
    if (_currentBlog.imageUrl == null || _currentBlog.imageUrl!.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }

    return Image.network(
      _currentBlog.imageUrl!,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  Widget _buildCommentSection() {
    if (_currentBlog.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('No comments yet. Be the first!'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentBlog.comments.length,
      itemBuilder: (context, index) {
        final comment = _currentBlog.comments[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(comment.userId),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.text),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(comment.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final likesCount = _currentBlog.likes.length;
    final commentsCount = _currentBlog.comments.length;

    return Scaffold(
      appBar: AppBar(title: Text(_currentBlog.title), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBlogImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentBlog.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(_currentBlog.author),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy')
                            .format(_currentBlog.publishDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentBlog.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _currentBlog.likes.contains(currentUserId)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _currentBlog.likes.contains(currentUserId)
                              ? Colors.red
                              : null,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text('$likesCount'),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment),
                      const SizedBox(width: 4),
                      Text('$commentsCount'),
                    ],
                  ),
                  const Divider(),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildCommentSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
