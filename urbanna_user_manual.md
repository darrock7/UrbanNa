## UrbanNa User Manual

## Overview

    UrbanNa is a mobile and web application that empowers users to report and track urban infrastructure issues such as potholes, broken streetlights, and hazards. Users can view geotagged reports on a map, validate the credibility of alerts, and contribute to community safety through civic engagement features.

## Installation Guide

    Web (Flutter Web)

    Open your browser and visit: https://urban-na-demo.web.app (placeholder link)

    No installation required.

    Mobile (Flutter Android/iOS)

    Prerequisites:

    Android 10+ or iOS 13+

    At least 150MB of free space

    Download the app (pending release on Play Store/TestFlight)

    Alternatively, run locally:

    flutter pub get
    flutter run -d <device>

## How to Run the Software (Local Dev Setup)

    Clone the repository:

    git clone https://github.com/darrock7/UrbanNa.git
    cd UrbanNa

    Run the app:

    flutter pub get
    flutter run

    How to Use the App

    Features

    View Map: See real-time alerts around your area

    Submit Alert: Add issues with description, severity, and optional image

    Rate Alerts: Mark others' alerts as helpful, unhelpful, or resolved (WIP)

    Profile View: Edit your name, email, and profile picture, as well as your stats as a user

    Settings: Access version info, dark mode toggle (WIP)

    🚧 Some features such as authentication and gamificiation are in progress and marked clearly in the UI.

## Reporting a Bug 

    1. Go to GitHub Issues

    2. Click "New Issue"

    3. Use our bug template:

        3a. Steps to reproduce

        3b. Expected vs actual result

        3c. Screenshot or error log (if available)

    For writing great reports: --> https://bugzilla.mozilla.org/page.cgi?id=bug-writing.html <--

## Known Bugs / Limitations

    User data is not yet persisted across sessions

    Some plugins (like camera) not supported in Flutter Web

    Image picker causes crash if platform support isn't handled (fixed for web/mobile)

