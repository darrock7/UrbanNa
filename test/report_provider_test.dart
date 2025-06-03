import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbanna/providers/report_provider.dart';
import 'package:urbanna/models/report.dart';

void main() {
  group('ReportProvider Tests', () {
    late ReportProvider reportProvider;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      // Passes the fake firestore instance to the provider
      reportProvider = ReportProvider(firestore: fakeFirestore);
    });

    test('should add report to Firestore successfully', () async {

      final report = Report(
        userId: '123',
        title: 'Safety',
        type: 'Pothole',
        description: 'Large pothole on Main Street',
        location: 'Main Street',
        severity: 'High',
        timestamp: DateTime(2024, 1, 15),
      );

      // Action
      await reportProvider.addReport(report);
      // Assertion test
      final collection = await fakeFirestore.collection('reports').get();
      expect(collection.docs.length, equals(1));
      
      final addedReport = Report.fromMap(collection.docs.first.data(), collection.docs.first.id);
      expect(addedReport.title, equals('Safety'));
      expect(addedReport.type, equals('Pothole'));
      expect(addedReport.description, equals('Large pothole on Main Street'));
    });

    test('should delete report from Firestore successfully', () async {
      // Adds report
      final docRef = await fakeFirestore.collection('reports').add({
        'category': 'Infrastructure',
        'type': 'Broken Light',
        'description': 'Street light not working',
        'location': 'Oak Avenue',
        'severity': 'Medium',
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      // Verifies report was added
      var collection = await fakeFirestore.collection('reports').get();
      expect(collection.docs.length, equals(1));

      await reportProvider.deleteReport(docRef.id);
      collection = await fakeFirestore.collection('reports').get();
      expect(collection.docs.length, equals(0));
    });

    test('should stream reports in descending timestamp order', () async {
      // Adding multiple reports with different timestamps
      final report1 = {
        'category': 'Safety',
        'type': 'Pothole',
        'description': 'Old pothole',
        'location': 'First Street',
        'severity': 'Low',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 1)),
      };

      final report2 = {
        'category': 'Infrastructure',
        'type': 'Broken Light',
        'description': 'Recent light issue',
        'location': 'Second Street',
        'severity': 'High',
        'timestamp': Timestamp.fromDate(DateTime(2024, 1, 15)),
      };

      await fakeFirestore.collection('reports').add(report1);
      await fakeFirestore.collection('reports').add(report2);

      // Action and assertion test
      final stream = reportProvider.getReportsStream();
      
      await expectLater(
        stream,
        emits(predicate<List<Report>>((reports) {
          return reports.length == 2 &&
                 reports[0].description == 'Recent light issue' && // Most recent first
                 reports[1].description == 'Old pothole';
        })),
      );
    });

    test('should handle empty Firestore collection', () async {
      // Action and assertion test
      final stream = reportProvider.getReportsStream();
      
      await expectLater(
        stream,
        emits(predicate<List<Report>>((reports) => reports.isEmpty)),
      );
    });

    test('should notify listeners when adding report', () async {

      bool notified = false;
      reportProvider.addListener(() {
        notified = true;
      });

      final report = Report(
        userId: '145',
        title: 'Environment',
        type: 'Litter',
        description: 'Trash on sidewalk',
        location: 'Park Avenue',
        severity: 'Low',
      );

      // Action
      await reportProvider.addReport(report);
      // Assertion test
      expect(notified, isTrue);
    });
  });
}

