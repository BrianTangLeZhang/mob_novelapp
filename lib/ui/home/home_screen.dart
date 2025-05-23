import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/service/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = NovelRepoSupabase();
  var novels = <Novel>[];
  final storageService = StorageService();
  Uint8List? bytes;

  @override
  void initState() {
    _refresh();
    super.initState();
  }

  void _refresh() async {
    final res = await repo.getAllNovels();
    setState(() {
      novels = res;
    });
  }

  void _navigateToNovel(Novel novel) {
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: novels.length,
          itemBuilder:
              (context, index) => NovelItem(
                novel: novels[index],
                onClickItem: (novel) => _navigateToNovel(novel),
                storageService: storageService,
              ),
        ),
      ),
    );
  }
}

class NovelItem extends StatefulWidget {
  const NovelItem({
    super.key,
    required this.novel,
    required this.onClickItem,
    this.storageService,
  });

  final Novel novel;
  final Function(Novel) onClickItem;
  final StorageService? storageService;

  @override
  State<NovelItem> createState() => _NovelItemState();
}

class _NovelItemState extends State<NovelItem> {
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    if (widget.storageService != null) {
      final imageBytes = await widget.storageService!.getImage(
        widget.novel.cover,
      );
      setState(() {
        bytes = imageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => widget.onClickItem(widget.novel),
        child: Column(
          children: [
            Row(
              children: [
                if (bytes != null)
                  Image.memory(
                    bytes!,
                    height: 300.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  ),
                if (bytes == null)
                  const SizedBox(
                    height: 300.0,
                    width: 150.0,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
