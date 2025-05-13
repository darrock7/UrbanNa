import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';


void setupTestDb() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
