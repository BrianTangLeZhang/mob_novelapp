import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';
import 'package:mob_novelapp/service/storage_service.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';
import 'package:mob_novelapp/ui/home/novelItem.dart';

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
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(8),
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                children:
                    novels.map((novel) {
                      return NovelItem(
                        novel: novel,
                        onClickItem: _navigateToNovel,
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
