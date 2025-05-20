import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbanna/screens/home_screen.dart';  
import 'package:urbanna/providers/report_provider.dart';  
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:urbanna/helpers/data_helper.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await deleteOldDb();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ReportProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanNa Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'UrbanNa'),  
    );
  }
}

Future<void> deleteOldDb() async {
  final dir = await getDatabasesPath();
  final path = join(dir, DataHelper.dataStorage);
  final dbFile = File(path);

  if (await dbFile.exists()) {
    await dbFile.delete();
    print('🗑️ Deleted old database at: $path');
  } else {
    print('ℹ️ No existing database found at: $path');
  }
}