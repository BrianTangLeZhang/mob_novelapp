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

class EditChapterScreen extends ConsumerStatefulWidget {
  const EditChapterScreen({
    super.key,
    required this.novelId,
    required this.index,
  });
  final String novelId;
  final int index;

  @override
  ConsumerState<EditChapterScreen> createState() => _EditChapterScreenState();
}

class _EditChapterScreenState extends ConsumerState<EditChapterScreen> {
  final repo = ChapterRepoSupabase();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final storageService = StorageService();
  Chapter? chapter;
  final List<File> _imageFiles = [];
  final List<Uint8List> bytesList = [];

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  void _loadChapter() async {
    final res = await repo.getChapter(widget.novelId, widget.index);
    if (!mounted || res == null) return;

    _titleController.text = res.title;
    _contentController.text = res.content;

    if (res.images != null && res.images!.isNotEmpty) {
      final loadedBytes = await Future.wait(
        res.images!.map((img) => storageService.getImage(img)),
      );

      if (mounted) {
        setState(() {
          chapter = res;
            _imageFiles.addAll(res.images!.map((img) => File(img)));
          bytesList.addAll(loadedBytes.whereType<Uint8List>());
        });
      }
    }
  }

  void _pickImage() async {
    final files = await _imagePicker.pickMultiImage();
    if (files.isNotEmpty && mounted) {
      setState(() {
        for (var file in files) {
          final imageFile = File(file.path);
          _imageFiles.add(imageFile);
          file.readAsBytes().then((bytes) {
            setState(() {
              bytesList.add(bytes);
            });
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
    final title = _titleController.text.trim();
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      _showSnackBar("Please fill in all fields.");
      return;
    }

    try {
      if (chapter != null &&
          chapter!.images != null &&
          chapter!.images!.isNotEmpty) {
        for (final image in chapter!.images!) {
          await storageService.deleteImage(image);
        }
      }

      final List<String> selectedImages = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      for (int i = 0; i < bytesList.length; i++) {
        final imageName =
            "img_${widget.novelId}${widget.index}${i}_$timestamp.jpg";
        selectedImages.add(imageName);
        await storageService.uploadImage(imageName, bytesList[i]);
      }

      final updatedChapter = Chapter(
        novel_id: widget.novelId,
        index: widget.index,
        title: title,
        content: content,
        images: selectedImages,
      );

      await repo.updateChapter(updatedChapter);

      if (mounted) {
        _showSnackBar('Chapter updated successfully');
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to update chapter: $e');
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
