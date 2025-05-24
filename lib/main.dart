import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';
import 'package:mob_novelapp/secret.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ypptdpalkjuinxlnpcxy.supabase.co',
    anonKey: anon,
  );

  final currentSession = Supabase.instance.client.auth.currentSession;
  final currentUser = currentSession?.user;

  if (currentUser != null) {
    final profile =
        await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', currentUser.id)
            .maybeSingle();

    runApp(
      ProviderScope(
        overrides: [
          authUserProvider.overrideWith((ref) => currentUser),
          userProfileProvider.overrideWith((ref) => profile),
        ],
        child: MyApp(),
      ),
    );
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Your Novels World!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: GoRouter(
        initialLocation: Navigation.initial,
        routes: Navigation.routes,
      ),
    );
  }
}
