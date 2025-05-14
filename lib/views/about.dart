import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {

  const AboutView( {super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About UrbanNa")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About UrbanNa",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "UrbanNa is a community-powered platform that makes it easy to report and track urban issues in your neighborhood.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Features:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text("- Submit alerts for construction or hazards"),
              const Text("- Upload photos and set severity levels"),
              const Text("- View active alerts on a city-wide map"),
              const Text("- Rate alerts submitted by other users"),
              const SizedBox(height: 16),
              const Text(
                "Getting Started:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text("1. Go to the Map tab and tap ➕ to submit an alert"),
              const Text("2. Fill out the form with accurate details"),
              const Text("3. Share alerts to help improve your city"),
              const Text("4. Check out the alerts on the map, the color will correspond to the severity level"),
            ],
          ),
        ),
      ),
    );
  }
}