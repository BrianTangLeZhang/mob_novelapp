import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/chapter.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/chapter_repo.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class DetailsNovelScreen extends ConsumerStatefulWidget {
  const DetailsNovelScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<DetailsNovelScreen> createState() => _DetailsNovelScreenState();
}

class _DetailsNovelScreenState extends ConsumerState<DetailsNovelScreen> {
  final repo = NovelRepoSupabase();
  final chapterRepo = ChapterRepoSupabase();
  final storageService = StorageService();

  Novel? novel;
  List<Chapter>? chapters;
  Uint8List? bytes;
  bool isLoading = true;
  bool chaptersLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNovel();
    _loadChapters();
  }

  void _loadNovel() async {
    setState(() => isLoading = true);
    final res = await repo.getNovelById(widget.id);
    final imageBytes = await storageService.getImage(res!.cover);
    setState(() {
      novel = res;
      bytes = imageBytes;
      isLoading = false;
    });
  }

  void _loadChapters() async {
    setState(() => chaptersLoading = true);
    final res = await chapterRepo.getChapterByNovelId(widget.id);
    setState(() {
      chapters = res;
      chaptersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.read(userProfileProvider);
    return AppScaffold(
      title: novel?.title ?? "Novel Details",
      floatingActionButton:
          novel?.user_id == profile!["id"]
              ? FloatingActionButton(
                onPressed: () {
                  // TODO: Add Chapter
                },
                backgroundColor: Colors.black,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              bytes!,
                              height: 200,
                              width: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                novel!.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text("Author: ${novel!.author}"),
                              const SizedBox(height: 10),
                              Text(
                                "Description: ${novel!.description}",
                                style: const TextStyle(fontSize: 14),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (novel!.user_id == profile["id"]) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            backgroundColor: Colors.black,
                            child: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              final res = await context.pushNamed(
                                Screen.updateNovel.name,
                                pathParameters: {"id": novel!.id!},
                              );
                              if (res == true) {
                                _loadNovel();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            backgroundColor: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              final res = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text("Delete Novel"),
                                      content: const Text(
                                        "Are you sure you want to delete this novel?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );

                              if (res == true) {
                                await storageService.deleteImage(novel!.cover);
                                await repo.deleteNovel(novel!.id!);
                                context.pushNamed(Screen.home.name);
                              }
                            },
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    const Text(
                      "Chapters",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 8),

                    Expanded(
                      child:
                          chaptersLoading
                              ? const Center(child: CircularProgressIndicator())
                              : (chapters == null || chapters!.isEmpty)
                              ? const Center(
                                child: Text(
                                  "No chapters added yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                              : ListView.separated(
                                itemCount: chapters!.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final chapter = chapters![index];
                                  return ListTile(
                                    title: Text(chapter.title),
                                    onTap: () {
                                      // TODO: Navigate to chapter details
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
