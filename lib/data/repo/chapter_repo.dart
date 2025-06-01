import 'package:mob_novelapp/data/model/chapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChapterRepoSupabase {
  static final ChapterRepoSupabase _instance = ChapterRepoSupabase._init();

  ChapterRepoSupabase._init();

  factory ChapterRepoSupabase() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> addChapter(Chapter chapter) async {
    await supabase.from('chapters').insert(chapter.toMap());
  }

  Future<Chapter?> getChapter(String novelId, int index) async {
    final res =
        await supabase
            .from("chapters")
            .select()
            .eq("novel_id", novelId)
            .eq("index", index)
            .maybeSingle();
    return Chapter.fromMap(res!);
  }

  Future<List<Chapter?>> getChapterByNovelId(String id) async {
    final res = await supabase.from("chapters").select().eq('novel_id', id).order("index",ascending: true);
    if (res.isEmpty) return [];
    return res.map((data) => Chapter.fromMap(data)).toList();
  }

  Future<List<Chapter>> getAllChapters() async {
    final res = await supabase
        .from("chapters")
        .select()
        .order('id', ascending: true);
    return res.map((data) => Chapter.fromMap(data)).toList();
  }

  Future<void> updateChapter(Chapter chapter) async {
    await supabase
        .from("chapters")
        .update(chapter.toMap())
        .eq('novel_id', chapter.novel_id)
        .eq('index', chapter.index);
  }

  Future<void> deleteChapter(String novelId, int id) async {
    await supabase
        .from("chapters")
        .delete()
        .eq("novel_id", novelId)
        .eq('id', id);
  }
}
