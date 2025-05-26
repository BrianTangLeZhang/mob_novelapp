import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/service/storage_service.dart';

class NovelItem extends StatefulWidget {
  const NovelItem({super.key, required this.novel, required this.onClickItem});

  final Novel novel;
  final Function(Novel) onClickItem;

  @override
  State<NovelItem> createState() => NovelItemState();
}

class NovelItemState extends State<NovelItem> {
  Uint8List? bytes;
  final storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    final imageBytes = await storageService.getImage(widget.novel.cover);
    setState(() {
      bytes = imageBytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClickItem(widget.novel),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (bytes != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.memory(bytes!, height: 180, fit: BoxFit.cover),
              )
            else
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.novel.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
