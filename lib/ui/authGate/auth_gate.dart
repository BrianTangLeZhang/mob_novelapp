import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/nav/navigation.dart';
import 'package:mob_novelapp/providers/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);

    if (user != null) {
      Future.microtask(() => context.pushReplacementNamed(Screen.home.name));
    } else {
      Future.microtask(() => context.pushReplacementNamed(Screen.login.name));
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
