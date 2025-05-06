import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {

  const AboutView( {super.key});
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Description: UrbanNa is a mobile application that helps users find and connect with local services and businesses.'),
        Text('Version: 1.0.0'),
      ],
    );
  }
}