import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the selected date
import 'package:image_picker/image_picker.dart'; // For image selection
import 'dart:io';

class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({super.key});

  @override
  _CreateBlogScreenState createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();

  String? selectedCategory;
  File? _selectedImage;
  DateTime? _publishDate;

  final List<String> categories = [
    'Technology',
    'Lifestyle',
    'Education',
    'Health',
    'Business'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _publishDate) {
      setState(() {
        _publishDate = pickedDate;
      });
    }
  }

  void submitBlog() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _authorController.text.isNotEmpty &&
        selectedCategory != null &&
        _publishDate != null) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'author': _authorController.text,
        'category': selectedCategory!,
        'image': _selectedImage?.path, // Store image path if selected
        'publishDate': DateFormat('yyyy-MM-dd').format(_publishDate!),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Blog')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Blog Title'),
              ),
              TextField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author Name'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Select Category'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Blog Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  _publishDate == null
                      ? 'Select Publish Date'
                      : 'Publish Date: ${DateFormat('yyyy-MM-dd').format(_publishDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Upload Image'),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(_selectedImage!, height: 100),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitBlog,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
