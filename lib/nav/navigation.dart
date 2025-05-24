import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/ui/authGate/auth_gate.dart';
import 'package:mob_novelapp/ui/home/home_screen.dart';
import 'package:mob_novelapp/ui/login/login_screen.dart';

class Navigation {
  static const initial = "/authGate";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: Screen.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/authGate',
      name: Screen.authGate.name,
      builder: (context, state) => const AuthGate(),
    ),
  ];
}

enum Screen {
  login,
  home,
  addNovel,
  updateNovel,
  addChapter,
  updateChapter,
  detailNovel,
  readingChapter,
  authGate,
}
