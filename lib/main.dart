import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        child: const MyApp(),
      ),
    );
  } else {
    runApp(const ProviderScope(child: MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Novel's World!",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: Navigation.router,
    );
  }
}
