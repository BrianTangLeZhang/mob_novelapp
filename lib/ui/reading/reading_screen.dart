import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/chapter.dart';
import 'package:mob_novelapp/data/repo/chapter_repo.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key, required this.novelId, required this.index});

  final String novelId;
  final int index;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final repo = ChapterRepoSupabase();
  final storageService = StorageService();
  bool isLoading = true;
  List<Uint8List?> bytes = [];
  Chapter? chapter;
  bool isAuthorOrAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  void _loadChapter() async {
    setState(() => isLoading = true);

    final res = await repo.getChapter(widget.novelId, widget.index);
    if (res == null) {
      setState(() {
        isLoading = false;
        context.pop(true);
        _snackbar("Chapter not found");
      });
      return;
    }
    List<Uint8List?> imageBytes = [];

    if (res.images != null && res.images!.isNotEmpty) {
      imageBytes = await Future.wait(
        res.images!.map((img) => storageService.getImage(img)),
      );
    }

    setState(() {
      chapter = res;
      bytes = imageBytes;
      isLoading = false;
    });
  }

  void _snackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      title: "",
      actions: [],
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Container(
                  color: Colors.amber[50],
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          chapter!.title,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Divider(height: 30),
                        Text(
                          chapter!.content,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 24),
                        if (bytes.isNotEmpty)
                          ...bytes.map(
                            (data) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.memory(data!, fit: BoxFit.contain),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
