import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:urbanna/providers/report_provider.dart';
import 'package:urbanna/models/report.dart';
import 'package:urbanna/screens/login_screen.dart';
import 'package:urbanna/screens/home_screen.dart';
import 'package:urbanna/views/map.dart';
import 'package:urbanna/views/profile.dart';
import 'package:urbanna/views/about.dart';

// Mock provider to avoid hanging FutureBuilder in MapView
class MockReportProvider extends ReportProvider {
  Future<void> loadReports() async {
    reports.clear();
    reports.add(
      Report(
        id: '1',
        description: 'I hate testing this app', 
        severity: 'low',
        location: '37.7749,-122.4194',
        category: 'General',
        type: 'Hazard',           
      ),
    );
  }

  @override
  Future<void> deleteReport(String id) async {}
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Widget createWidgetUnderTest(Widget child) {
    return ChangeNotifierProvider<ReportProvider>.value(
      value: MockReportProvider(),
      child: MaterialApp(home: child),
    );
  }

  testWidgets('Tab navigation between Map, Profile, and About', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const MyHomePage(
      title: 'UrbanNa',
      name: 'Test User',
      email: 'test@example.com',
    )));

    // Starting view should be MapView
    expect(find.byType(MapView), findsOneWidget);

    // Navigate to Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileView), findsOneWidget);

    // Navigate to About
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutView), findsOneWidget);

    // Back to Map
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    expect(find.byType(MapView), findsOneWidget);
  });

  testWidgets('Guest login navigates to MapView', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));

    // Tap the guest guest button (For quick access)
    await tester.tap(find.byKey(const Key('guestButton'))); // Testing Dev Guest Login
    await tester.pumpAndSettle(); 

    // Verify that the MapView is displayed
    expect(find.byType(MapView), findsOneWidget);
  });

  testWidgets('A successful Login button navigates to Mapview', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const LoginScreen()));

    // Enter text in the text fields
    await tester.enterText(find.byKey(const Key('emailField')), 'testing@gamil.com'); 
    await tester.enterText(find.byKey(const Key('nameField')), 'Darrick');

    // Tap the login button
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    // Verify that the MapView is displayed
    expect(find.byType(MapView), findsOneWidget);

  });
}
