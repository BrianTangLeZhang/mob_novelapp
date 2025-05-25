import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authUserProvider = StateProvider<User?>((ref) => null);

final userProfileProvider = StateProvider<Map<String, dynamic>?>((ref) => null);