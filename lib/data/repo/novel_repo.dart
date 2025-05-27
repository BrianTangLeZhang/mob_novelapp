import 'package:mob_novelapp/data/model/novel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NovelRepoSupabase {
  static final NovelRepoSupabase _instance = NovelRepoSupabase._init();

  NovelRepoSupabase._init();

  factory NovelRepoSupabase() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> addNovel(Novel novel) async {
    await supabase.from('novels').insert(novel.toMap());
  }

  Future<Novel?> getNovelById(String id) async {
    final res = await supabase.from("novels").select().eq('id', id).single();
    return Novel.fromMap(res);
  }

  Future<List<Novel>> getAllNovels() async {
    final res = await supabase
        .from("novels")
        .select()
        .order('id', ascending: true);
    return res.map((data) => Novel.fromMap(data)).toList();
  }

  Future<void> updateNovel(Novel novel) async {
    await supabase.from("novels").update(novel.toMap()).eq('id', novel.id!);
  }

  Future<void> deleteNovel(int id) async {
    await supabase.from("novels").delete().eq('id', id);
  }
}
