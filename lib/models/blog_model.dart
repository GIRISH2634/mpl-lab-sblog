import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {
  final String id;
  final String title;
  final String description;
  final String author;
  final String category;
  final DateTime publishDate;
  final String? imageUrl;
  final List<String> likes;
  final List<Comment> comments;

  Blog({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
    required this.publishDate,
    this.imageUrl,
    List<String>? likes,
    List<Comment>? comments,
  })  : likes = likes ?? [],
        comments = comments ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'category': category,
      'publishDate': Timestamp.fromDate(publishDate),
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      author: map['author'] as String,
      category: map['category'] as String,
      publishDate: (map['publishDate'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] as String?,
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
              ?.map(
                  (comment) => Comment.fromMap(comment as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Comment {
  final String userId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.userId,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'] as String,
      text: map['text'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
