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

  Future<List<Novel>> getAllNovelsByKeyword(
  String keyword,
  String order,
  bool asc,
) async {
  final res = await supabase
      .rpc('get_novels_with_chapter_count')
      .select();

   final List<dynamic> data = res;

  final filtered = data.where((item) {
    final title = item['title']?.toString().toLowerCase() ?? '';
    final author = item['author']?.toString().toLowerCase() ?? '';
    final kw = keyword.toLowerCase();
    return title.contains(kw) || author.contains(kw);
  }).toList();

  filtered.sort((a, b) {
    int comparison;
    if (order == "id") {
      comparison = (a['id'] ?? '').compareTo(b['id'] ?? '');
    } else {
      comparison =
          (a['chapter_count'] as int).compareTo(b['chapter_count'] as int);
    }
    return asc ? comparison : -comparison;
  });

  return filtered.map((data) {
    return Novel.fromMap({
      ...data,
      'chapter_count': data['chapter_count'] ?? 0,
    });
  }).toList();
}

  Future<void> updateNovel(Novel novel) async {
    await supabase.from("novels").update(novel.toMap()).eq('id', novel.id!);
  }

  Future<void> deleteNovel(String id) async {
    await supabase.from("novels").delete().eq('id', id);
  }
}
