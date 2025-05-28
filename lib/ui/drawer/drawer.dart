import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';

class AppScaffold extends ConsumerWidget {
  final Widget body;
  final String title;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    void navigateTo(String page) {
      context.pop();
      context.pushNamed(page);
    }

    final currentRouteName = ModalRoute.of(context)?.settings.name;
    final isHome = currentRouteName == Screen.home.name;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading:
            isHome
                ? Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
        actions: [
          if (isHome)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // context.pushNamed('search');
              },
            ),
        ],
      ),
      drawer:
          isHome
              ? Drawer(
                width: 200,
                backgroundColor: Colors.grey[900],
                child: ListView(
                  children: [
                    DrawerHeader(
                      child: Center(
                        child: Text(
                          profile != null
                              ? "Current User: ${profile['username']}"
                              : "User not logged in",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Home',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => navigateTo(Screen.home.name),
                    ),
                  ],
                ),
              )
              : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
