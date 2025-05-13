import 'package:flutter/material.dart';
import 'package:urbanna/models/report.dart';
import 'package:urbanna/helpers/data_helper.dart';


class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];

  List<Report> get reports => _reports;

  // Load all reports from the database
  Future<void> loadReports() async {
    final dbHelper = DataHelper.instance;
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllReports();

    _reports = List.generate(maps.length, (i) {
      return Report.fromMap(maps[i]);
    });

    notifyListeners();
  }

  // Add a new report to the database
  Future<void> addReport(Report report) async {
    final dbHelper = DataHelper.instance;
    await dbHelper.insertReport(report.toMap());

    await loadReports();  // Reload reports after adding the new one
    notifyListeners();
  }

  Future<void> deleteReport(int id) async {
  // Get the database instance from DataHelper
  final db = await DataHelper.instance.database;

  // Delete the report from the database using the table name and column name from DataHelper
  await db.delete(
    DataHelper.tableName, // Use the table name from DataHelper
    where: '${DataHelper.columnId} = ?', // Use the column name for the ID from DataHelper
    whereArgs: [id], // Use the ID as the argument
  );

  // Remove the report from the in-memory list of reports
  _reports.removeWhere((report) => report.id == id);

  // Notify listeners to update the UI
  notifyListeners();
}


}
