import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
 
import 'package:urbanna/providers/report_provider.dart';  
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:urbanna/helpers/data_helper.dart';
import 'package:urbanna/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize SQLite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // For development only - remove or comment out this line for production
  // await deleteOldDb();

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
    // Start listening for real-time updates from Firestore
    Future.microtask(() {
      Provider.of<ReportProvider>(context, listen: false).startRealtimeUpdates();
    });
    
    return MaterialApp(
      title: 'UrbanNa Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), 
    );
  }
}

Future<void> deleteOldDb() async {
  final dir = await getDatabasesPath();
  final path = join(dir, DataHelper.dataStorage);
  final dbFile = File(path);

  if (await dbFile.exists()) {
    await dbFile.delete();
    // ignore: avoid_print
    print('🗑️ Deleted old database at: $path');
  } else {
    // ignore: avoid_print
    print('ℹ️ No existing database found at: $path');
  }
}