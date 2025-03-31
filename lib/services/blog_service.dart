import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';

class BlogService {
  final CollectionReference _blogsCollection =
      FirebaseFirestore.instance.collection('blogs');

  Future<void> createBlog(Blog blog) async {
    await _blogsCollection.doc(blog.id).set(blog.toMap());
  }

  Future<List<Blog>> getBlogs() async {
    final snapshot = await _blogsCollection.get();
    return snapshot.docs
        .map((doc) => Blog.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Blog?> getBlog(String id) async {
    final doc = await _blogsCollection.doc(id).get();
    if (!doc.exists) return null;
    return Blog.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> toggleLike(String blogId, String userId) async {
    final doc = await _blogsCollection.doc(blogId).get();
    if (!doc.exists) throw Exception('Blog not found');

    final blog = Blog.fromMap(doc.data() as Map<String, dynamic>);
    final likes = List<String>.from(blog.likes);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await _blogsCollection.doc(blogId).update({'likes': likes});
  }

  Future<void> addComment(String blogId, Comment comment) async {
    final doc = await _blogsCollection.doc(blogId).get();
    if (!doc.exists) throw Exception('Blog not found');

    final blog = Blog.fromMap(doc.data() as Map<String, dynamic>);
    final comments = List<Comment>.from(blog.comments);
    comments.add(comment);

    await _blogsCollection.doc(blogId).update({
      'comments': comments.map((c) => c.toMap()).toList(),
    });
  }

  Future<void> updateBlog(Blog blog) async {
    await _blogsCollection.doc(blog.id).update(blog.toMap());
  }

  Future<void> deleteBlog(String id) async {
    await _blogsCollection.doc(id).delete();
  }
}
