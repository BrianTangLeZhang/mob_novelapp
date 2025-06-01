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
  String order = "id";
  bool asc = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _keywordController.addListener(_showResult);
    _showResult();
  }

  void _showResult() async {
    setState(() => isLoading = true);
    final res = await repo.getAllNovelsByKeyword(
      _keywordController.text,
      order,
      asc,
    );
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

  void _showSortDialog() async {
    final sortFields = {"Latest (ID)": "id", "Most Chapters": "chapter_count"};

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String selectedOrder = order;
        bool selectedAsc = asc;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Sort Options"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedOrder,
                    items:
                        sortFields.entries
                            .map(
                              (entry) => DropdownMenuItem<String>(
                                value: entry.value,
                                child: Text(entry.key),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedOrder = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: "Sort by"),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Ascending"),
                      Switch(
                        value: selectedAsc,
                        onChanged: (val) {
                          setState(() => selectedAsc = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    context.pop({'order': selectedOrder, 'asc': selectedAsc});
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        order = result['order'];
        asc = result['asc'];
      });
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
              width: 300,
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
        IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
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
