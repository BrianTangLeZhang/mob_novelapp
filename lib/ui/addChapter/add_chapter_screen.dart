import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mob_novelapp/data/model/chapter.dart';
import 'package:mob_novelapp/data/repo/chapter_repo.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class AddChapterScreen extends ConsumerStatefulWidget {
  final String novelId;
  const AddChapterScreen({super.key, required this.novelId});

  @override
  ConsumerState<AddChapterScreen> createState() => _AddChapterScreenState();
}

class _AddChapterScreenState extends ConsumerState<AddChapterScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final storageService = StorageService();
  final List<File> _imageFiles = [];
  final List<Uint8List> bytesList = [];

  void _pickImage() async {
    final files = await _imagePicker.pickMultiImage();
    if (files.isNotEmpty && mounted) {
      setState(() {
        for (var file in files) {
          final imageFile = File(file.path);
          _imageFiles.add(imageFile);
          file.readAsBytes().then((bytes) {
            if (mounted) {
              setState(() {
                bytesList.add(bytes);
              });
            }
          });
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      bytesList.removeAt(index);
    });
  }

  void _saveChapter() async {
    final chapterRepo = ChapterRepoSupabase();
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }
    
    try {
      final chapters = await chapterRepo.getChapterByNovelId(widget.novelId);
      final index = chapters.length;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final List<String> selectedImages = [];

      if (_imageFiles.isNotEmpty) {
        for (int i = 0; i < _imageFiles.length; i++) {
          selectedImages.add("img_${widget.novelId}$index${i}_$timestamp.jpg");
        }

        for (int i = 0; i < selectedImages.length; i++) {
          await storageService.uploadImage(selectedImages[i], bytesList[i]);
        }
      }

      final chapter = Chapter(
        novel_id: widget.novelId,
        index: index,
        title: title,
        content: content,
        images: selectedImages,
      );

      await chapterRepo.addChapter(chapter);
      if (mounted) {
        _showSnackBar('Chapter added successfully');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to add chapter: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      title: 'New Chapter',
      actions: [
        IconButton(
          onPressed: _saveChapter,
          icon: const Icon(Icons.save, color: Colors.white),
        ),
      ],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: TextFormField(
                    controller: _contentController,
                    scrollController: _scrollController,
                    maxLines: null,
                    minLines: 30,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      labelText: 'Content...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (bytesList.isNotEmpty)
                  SizedBox(
                    height: 106,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            bytesList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Stack(
                                  children: [
                                    Image.memory(
                                      file,
                                      height: 106,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          color: Colors.red[500],
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.black,
        child: Icon(Icons.image, color: Colors.white),
      ),
    );
  }
}
