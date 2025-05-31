import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/data/model/novel.dart';
import 'package:mob_novelapp/data/repo/novel_repo.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';
import 'package:mob_novelapp/ui/home/novelItem.dart';

class SearchingScreen extends ConsumerStatefulWidget {
  const SearchingScreen({super.key});

  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen> {
  final repo = NovelRepoSupabase();
  final _keywordController = TextEditingController();
  var novels = <Novel>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(_showResult);
    _showResult();
  }

  void _showResult() async {
    setState(() => isLoading = true);
    final res = await repo.getAllNovelsByKeyword(_keywordController.text);
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
      _showResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: null,
      resizeToAvoidBottomInset: true,
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: 340,
              child: TextField(
                controller: _keywordController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(6),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
      ],
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
                        "No Result",
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
    );
  }
}
