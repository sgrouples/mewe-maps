
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mewe_maps/repositories/storage/storage_repository.dart';
import 'package:mewe_maps/services/supabase/supabase.dart';

Future<void> initializeIsolate() async {
  await dotenv.load(fileName: ".env");

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    exit(1);
  };

  await initializeSupabase();
  await StorageRepository.initialize();
}
