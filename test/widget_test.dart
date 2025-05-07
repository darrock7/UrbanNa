// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:urbanna/main.dart';
import 'package:urbanna/views/about.dart';
import 'package:urbanna/views/map.dart';
import 'package:urbanna/views/profile.dart';

void main() {
  testWidgets('Profile tab shows correct content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Checks that the initial state of the app is the MapView
    expect(find.byType(MapView), findsOneWidget);
    expect(find.byType(ProfileView), findsNothing);

    // After tapping the Profile tab, it should show the ProfileView, sync it up
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    //verify initial value
    expect(find.text('0'), findsOneWidget); // still at 0
    expect(find.text('-1'), findsNothing);  // shouldn't go below 0

    // Verify that ProfileView is shown with the correct information (mock data for now)
    expect(find.byType(ProfileView), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);
    expect(find.text('johnsmith@uw.edu'), findsOneWidget);
  });

  testWidgets('About tab shows correct content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Makes sure the app's initial state is the MapView
    expect(find.byType(MapView), findsOneWidget);
    expect(find.byType(AboutView), findsNothing);

    // Taps the About tab
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    // Checks that the app is directed to show the AboutView
    expect(find.byType(AboutView), findsOneWidget);
    
    // Verify that the content shown in AboutView is correct
    expect(find.text('Description: UrbanNa is a mobile application that helps users find and connect with local services and businesses.'), 
    findsOneWidget);
    expect(find.text('Version: 1.0.0'), findsOneWidget);
  });
}
