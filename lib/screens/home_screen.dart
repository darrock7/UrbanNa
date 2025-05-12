import 'package:flutter/material.dart';
import 'package:urbanna/views/map.dart';
import 'package:urbanna/views/profile.dart';
import 'package:urbanna/views/about.dart';
import 'package:urbanna/views/settings.dart';
import 'package:urbanna/views/submit_alert.dart';

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
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: IndexedStack(
          index: _currTabIndex,
          children: const [
            MapView(), // Map view
            ProfileView(name: 'John Smith', email: 'johnsmith@uw.edu'), // Profile view
            AboutView(), // About view
            SettingsView(), // Settings view
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
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
      ),
          floatingActionButton: _currTabIndex == 0 ? FloatingActionButton(
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
