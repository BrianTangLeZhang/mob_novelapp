import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
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
    debugPrint(res.toString());
    debugPrint("**************\n**********");
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
            Text(
              "Novels",
              style: (TextStyle(fontSize: 25)),
              textAlign: TextAlign.center,
            ),
            Divider(),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                children:
                    novels.map((novel) {
                      return Column(
                        children: [Text(novel.title), Text(novel.description)],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await context.pushNamed(Screen.addNovel.name);
          if (res == true) {
            _refresh();
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
