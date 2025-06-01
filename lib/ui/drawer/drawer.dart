import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppScaffold extends ConsumerWidget {
  static final supabase = Supabase.instance.client;
  final Widget body;
  final String? title;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final List<Widget> actions;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.floatingActionButton,
    required this.resizeToAvoidBottomInset,
    required this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    void navigateTo(String page) {
      context.pop();
      context.pushNamed(page);
    }

    void logout() async {
      await supabase.auth.signOut();
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().disconnect();
      }
      ref.invalidate(userProfileProvider);
      ref.invalidate(authUserProvider);
      context.pushNamed(Screen.authGate.name);
    }

    final currentRouteName = ModalRoute.of(context)?.settings.name;
    final isHome = currentRouteName == Screen.home.name;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(title ?? "", style: const TextStyle(color: Colors.white)),
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
                  onPressed: () => context.pop(true),
                ),
        actions: actions,
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
                    profile != null
                        ? ListTile(
                          title: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          onTap: logout,
                        )
                        : SizedBox(),
                  ],
                ),
              )
              : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
