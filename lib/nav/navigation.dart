import 'package:go_router/go_router.dart';
import 'package:mob_novelapp/ui/addChapter/add_chapter_screen.dart';
import 'package:mob_novelapp/ui/addNovel/add_novel_screen.dart';
import 'package:mob_novelapp/ui/authGate/auth_gate.dart';
import 'package:mob_novelapp/ui/detailNovel/details_novel.dart';
import 'package:mob_novelapp/ui/editChapter/edit_chapter_screen.dart';
import 'package:mob_novelapp/ui/editNovel/edit_novel_screen.dart';
import 'package:mob_novelapp/ui/home/home_screen.dart';
import 'package:mob_novelapp/ui/login/login_screen.dart';
import 'package:mob_novelapp/ui/reading/reading_screen.dart';
import 'package:mob_novelapp/ui/search/searching_screen.dart';

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
        path: "/search",
        name: Screen.searching.name,
        builder: (context, state) => const SearchingScreen(),
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
      GoRoute(
        path: "/addChapter/:novelId",
        name: Screen.addChapter.name,
        builder:
            (context, state) =>
                AddChapterScreen(novelId: state.pathParameters["novelId"]!),
      ),
      GoRoute(
        path: "/editChapter/:novelId/:index",
        name: Screen.updateChapter.name,
        builder:
            (context, state) => EditChapterScreen(
              novelId: state.pathParameters["novelId"]!,
              index: int.parse(state.pathParameters["index"]!), // 转换成 int
            ),
      ),
      GoRoute(
        path: "/reading/:novelId/:index",
        name: Screen.readingChapter.name,
        builder:
            (context, state) => ReadingScreen(
              novelId: state.pathParameters["novelId"]!,
              index: int.parse(state.pathParameters["index"]!), // 转换成 int
            ),
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
  searching,
  updateChapter,
  detailNovel,
  readingChapter,
  authGate,
}
