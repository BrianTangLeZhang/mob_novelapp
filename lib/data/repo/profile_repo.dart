import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mob_novelapp/data/model/profile.dart';

class ProfileRepoSupabase {
  static final ProfileRepoSupabase _instance = ProfileRepoSupabase._init();

  ProfileRepoSupabase._init();

  factory ProfileRepoSupabase() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<Profile?> getUser(String userId) async {
    final res =
        await supabase.from('profiles').select().eq('id', userId).single();
    return Profile.fromMap(res);
  }
}
