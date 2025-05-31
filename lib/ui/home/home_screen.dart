import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';
import 'package:mob_novelapp/ui/home/novelItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final repo = NovelRepoSupabase();
  var novels = <Novel>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    setState(() => isLoading = true);
    final res = await repo.getAllNovels();
    setState(() {
      novels = res;
      isLoading = false;
    });
  }

  void _navigateToNovel(String? id) async {
    final res = await context.pushNamed(
      Screen.detailNovel.name,
      pathParameters: {"id": id!},
    );
    if (res == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            context.pushNamed(Screen.searching.name);
          },
        ),
      ],
      title: 'Home',
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (_) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (novels.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Novels Added Yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  } else {
                    return GridView.count(
                      padding: const EdgeInsets.all(8),
                      crossAxisCount: 2,
                      childAspectRatio: 0.52,
                      children:
                          novels
                              .map(
                                (novel) => NovelItem(
                                  novel: novel,
                                  onClickItem:
                                      (_) => _navigateToNovel(novel.id),
                                ),
                              )
                              .toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await context.pushNamed(Screen.addNovel.name);
          if (res == true) _refresh();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
