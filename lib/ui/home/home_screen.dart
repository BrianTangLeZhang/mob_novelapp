import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = NovelRepoSupabase();
  final storageService = StorageService();
  var novels = <Novel>[];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    final res = await repo.getAllNovels();
    setState(() {
      novels = res;
    });
  }

  void _navigateToNovel(Novel novel) {
    // TODO: Redirect to the novel page
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Home',
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search novels',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(8),
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                children:
                    novels.map((novel) {
                      return Card(
                        child: GestureDetector(
                          onTap: () => _navigateToNovel(novel),
                          child: Column(
                            children: [
                              FutureBuilder<Uint8List?>(
                                future: storageService.getImage(novel.cover),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return Image.memory(
                                      snapshot.data!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return const SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  novel.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(Screen.addNovel.name),
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _NovelItem extends StatefulWidget {
  const _NovelItem({
    required this.novel,
    required this.onClickItem,
    this.storageService,
  });

  final Novel novel;
  final Function(Novel) onClickItem;
  final StorageService? storageService;

  @override
  State<_NovelItem> createState() => _NovelItemState();
}

class _NovelItemState extends State<_NovelItem> {
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
