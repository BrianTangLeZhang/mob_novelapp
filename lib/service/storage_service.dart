import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final _instance = StorageService.init();

  StorageService.init();

  factory StorageService() {
    return _instance;
  }

  final supabase = Supabase.instance.client;

  Future<void> uploadImage(String name, Uint8List bytes) async {
    final res = await supabase.storage
        .from("images")
        .uploadBinary(name, bytes, fileOptions: FileOptions(upsert: true));
    debugPrint("File uploaded $res");
  }

  Future<Uint8List?> getImage(String name) async {
    final url = supabase.storage.from("images").getPublicUrl(name);
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      return null;
    }
    return res.bodyBytes;
  }
}