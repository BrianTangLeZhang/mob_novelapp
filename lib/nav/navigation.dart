import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/ui/home/home_screen.dart';

class Navigation {
  static const initial = "/login";
  static final routes = [
    GoRoute(
      path: "/",
      name: Screen.home.name,
      // builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path:'/login',
      name:Screen.login.name,
      // builder: (context, state) => const LoginScreen(),
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
}
