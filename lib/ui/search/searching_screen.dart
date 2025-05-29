import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mob_novelapp/ui/drawer/drawer.dart';

class SearchingScreen extends ConsumerStatefulWidget {
  const SearchingScreen({super.key});

  @override
  ConsumerState<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends ConsumerState<SearchingScreen> {
  final _keywordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: null,
      resizeToAvoidBottomInset: true,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 200,
            child: TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ),
        ),
      ],
      body: Text("Hi"),
    );
  }
}
