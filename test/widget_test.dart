import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:urbanna/providers/report_provider.dart';
import 'package:urbanna/screens/login_screen.dart';
import 'package:urbanna/views/submit_alert.dart';


void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;


  Widget createWidgetUnderTest(Widget child) {
    final fakeFirestore = FakeFirebaseFirestore();
    final reportProvider = ReportProvider(firestore: fakeFirestore);

    return ChangeNotifierProvider<ReportProvider>.value(
      value: reportProvider,
      child: MaterialApp(home: child),
    );
  }

 testWidgets('SubmitAlertView renders all required fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const SubmitAlertView()));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Severity'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Upload Photo'), findsOneWidget);
    expect(find.text('Submit Alert'), findsOneWidget);
  });

  testWidgets('Does not crash on empty submission', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const SubmitAlertView()));
    await tester.tap(find.text('Submit Alert'));
    await tester.pumpAndSettle();

    // No crash, widget remains on screen
    expect(find.byType(SubmitAlertView), findsOneWidget);
  });

  testWidgets('Can change dropdown values', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const SubmitAlertView()));

    await tester.tap(find.text('Construction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hazard').last);
    await tester.pumpAndSettle();
    expect(find.text('Hazard'), findsOneWidget);

    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('Typing title and description updates fields', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const SubmitAlertView()));

    await tester.enterText(find.byType(TextField).at(0), 'Sinkhole');
    await tester.enterText(find.byType(TextField).at(1), 'A big sinkhole near the road');

    expect(find.text('Sinkhole'), findsOneWidget);
    expect(find.text('A big sinkhole near the road'), findsOneWidget);
  });



  testWidgets('Login does not proceed without name/email', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // Still on LoginScreen — not navigated
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
