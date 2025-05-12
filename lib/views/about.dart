import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {

  const AboutView( {super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About UrbanNa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Welcome to UrbanNa!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "UrbanNa is a community-powered platform that makes it easy to report and track urban issues in your neighborhood.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "What you can do:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text("- Submit alerts for construction or hazards"),
            Text("- Upload photos and set severity levels"),
            Text("- View active alerts on a city-wide map"),
            Text("- Rate alerts submitted by other users"),
            SizedBox(height: 16),
            Text(
              "Getting Started:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text("1. Go to the Map tab and tap ➕ to submit an alert"),
            Text("2. Fill out the form with accurate details"),
            Text("3. Share alerts to help improve your city"),
            SizedBox(height: 24),
            Text("Version: 1.0.0"),
          ],
        ),
      ),
    );
  }
}