import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/ui/addNovel/add_novel_screen.dart';
import 'package:mob_novelapp/ui/authGate/auth_gate.dart';
import 'package:mob_novelapp/ui/detailNovel/details_novel.dart';
import 'package:mob_novelapp/ui/editNovel/edit_novel_screen.dart';
import 'package:mob_novelapp/ui/home/home_screen.dart';
import 'package:mob_novelapp/ui/login/login_screen.dart';

class Navigation {
  static const initial = "/authGate";
  static final router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: '/authGate',
        name: Screen.authGate.name,
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/login',
        name: Screen.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: "/",
        name: Screen.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: "/addNovel",
        name: Screen.addNovel.name,
        builder: (context, state) => const AddNovelScreen(),
      ),
      GoRoute(
        path: "/detailNovel/:id",
        name: Screen.detailNovel.name,
        builder:
            (context, state) =>
                DetailsNovelScreen(id: state.pathParameters["id"]!),
      ),
      GoRoute(
        path: "/updateNovel/:id",
        name: Screen.updateNovel.name,
        builder:
            (context, state) =>
                EditNovelScreen(id: state.pathParameters["id"]!),
      ),
    ],
  );
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
