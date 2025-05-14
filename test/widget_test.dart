import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:urbanna/main.dart';
import 'package:urbanna/providers/report_provider.dart';
import 'package:urbanna/views/map.dart';
import 'package:urbanna/views/profile.dart';
import 'package:urbanna/views/about.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  testWidgets('Tab navigation between Map, Profile, and About',
      (WidgetTester tester) async {

    // Build our app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ReportProvider()),
          ],
          child: const MyApp(),
        ),
      );
    // Verify that the MapView is displayed first (it is the default)
    expect(find.byType(MapView), findsOneWidget);

    // Tap on the Profile tab and tests if the ProfileView is displayed
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProfileView), findsOneWidget);

    // Tap on the About tab and tests if the AboutView is displayed
    await tester.tap(find.text('About'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AboutView), findsOneWidget);

    // Tap back on the Map tab and tests if the MapView is displayed again
    await tester.tap(find.text('Map'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MapView), findsOneWidget);
  });
}
