import 'package:flutter/material.dart';
import 'package:urbanna/views/profile.dart';
import 'package:urbanna/views/about.dart';
import 'package:urbanna/views/settings.dart';
import 'package:urbanna/views/map.dart';
import 'package:urbanna/views/submit_alert.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanNa Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'UrbanNa Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
     bottomNavigationBar: NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          // Handle navigation here
          _currTabIndex = index;
        });
      },
        indicatorColor: theme.primaryColor,
        selectedIndex: _currTabIndex,
      destinations: const [
    NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
    NavigationDestination(icon: Icon(Icons.info_outline), label: 'About'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ), // This trailing comma makes auto-formatting nicer for build methods.
    body: Center(child: 
    switch (_currTabIndex) {
      0 => const MapView(),
      1 => const ProfileView(),
      2 => const AboutView(),
      3 => const SettingsView(),
      _ => const Placeholder(),
    },
    ),
    floatingActionButton: _currTabIndex == 0
    ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubmitAlertView()),
          );
        },
        tooltip: 'Submit Alert',
        child: const Icon(Icons.add),
      )
    : null,

    );
  }
}
