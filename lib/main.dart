import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:since_together/app.dart';
import 'package:since_together/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Supabase.initialize(
    url: SupabaseConstants.url,
    anonKey: SupabaseConstants.anonKey,
  );

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: MyApp()));
}
