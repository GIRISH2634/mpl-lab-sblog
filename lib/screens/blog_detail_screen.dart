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

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.blog.likes.contains(currentUserId);
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final storedBlogs = prefs.getString('myBlogs');

    if (storedBlogs != null) {
      List<Map<String, dynamic>> blogs =
          List<Map<String, dynamic>>.from(jsonDecode(storedBlogs));

      final index = blogs.indexWhere((blog) => blog['id'] == widget.blog.id);

      if (index != -1) {
        List<String> likes =
            List<String>.from(blogs[index]['likes'] ?? <String>[]);

        setState(() {
          if (likes.contains(currentUserId)) {
            likes.remove(currentUserId);
            widget.blog.likes.remove(currentUserId); // ✅ Update UI state
            isLiked = false;
          } else {
            likes.add(currentUserId);
            widget.blog.likes.add(currentUserId); // ✅ Update UI state
            isLiked = true;
          }

          blogs[index]['likes'] = likes; // ✅ Save to local storage
        });

        await prefs.setString('myBlogs', jsonEncode(blogs));
      } else {
        _showSnackBar("Blog not found");
      }
    } else {
      _showSnackBar("No blogs found in storage");
    }
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      userId: currentUserId,
      text: text,
    );

    final prefs = await SharedPreferences.getInstance();
    final storedBlogs = prefs.getString('myBlogs');

    if (storedBlogs != null) {
      List<Map<String, dynamic>> blogs =
          List<Map<String, dynamic>>.from(jsonDecode(storedBlogs));
      final index = blogs.indexWhere((blog) => blog['id'] == widget.blog.id);

      if (index != -1) {
        List<Map<String, dynamic>> comments =
            List<Map<String, dynamic>>.from(blogs[index]['comments'] ?? []);
        comments.insert(0, newComment.toMap());

        blogs[index]['comments'] = comments;
        widget.blog.comments.insert(0, newComment); // ✅ Update UI state

        await prefs.setString('myBlogs', jsonEncode(blogs));
        _commentController.clear();
        setState(() {});
      } else {
        _showSnackBar("Blog not found");
      }
    } else {
      _showSnackBar("No blogs found in storage");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildBlogImage() {
    if (widget.blog.imageUrl == null || widget.blog.imageUrl!.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }

    return Image.network(
      widget.blog.imageUrl!,
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
    if (widget.blog.comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('No comments yet. Be the first!'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.blog.comments.length,
      itemBuilder: (context, index) {
        final comment = widget.blog.comments[index];
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
    final likesCount = widget.blog.likes.length;
    final commentsCount = widget.blog.comments.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blog.title),
        elevation: 0,
      ),
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
                  Text(widget.blog.title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(widget.blog.author),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMM dd, yyyy')
                          .format(widget.blog.publishDate)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(widget.blog.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : null,
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
