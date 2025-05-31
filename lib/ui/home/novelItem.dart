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
            AspectRatio(
              aspectRatio: 1 / 1.6,
              child:
                  bytes != null
                      ? Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(bytes!),
                            fit: BoxFit.contain,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          color: Colors.white,
                        ),
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.novel.title.length > 15
                        ? '${widget.novel.title.substring(0, 15)}...'
                        : widget.novel.title,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.novel.author),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
