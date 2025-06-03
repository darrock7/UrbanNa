## UrbanNa Developer Guide

## Getting the Source Code

    git clone https://github.com/darrock7/UrbanNa.git
    cd UrbanNa

## Directory Structure

    lib/ -- Main Flutter application code
    
        views/ -- Screens like ProfileView, MapView, SettingsView

        widgets/ -- Reusable components

    test/ -- Unit and widget tests

    .github/workflows/ -- CI setup for GitHub Actions


## How to Build

    flutter pub get
    flutter run

    For backend:

    cd backend
    dart pub get
    dart run

## How to Test

    flutter test

    Run tests in CI via GitHub Actions. All tests in test/ are automatically triggered on PR or push to main.

## How to Add New Tests

    Create a file in test/, e.g., profile_test.dart

    Use flutter_test and mockito as needed

    Naming convention: <feature>_test.dart

    Run locally with:

    flutter test test/profile_test.dart

    ## CI/CD Pipeline

    We use GitHub Actions:

    Runs tests and lints on push and PR

    Config file: .github/workflows/flutter.yml

## Release Process

    To build a release:

    Update pubspec.yaml version

    Commit with message: Release vX.Y.Z

    Create a GitHub release and tag the commit

    (Optional) Deploy to Firebase or app stores

## Contribution Guide

    Branch off dev/feature-name

    Submit PR with clear description

    All code must be reviewed before merge

    Include test cases and link issue/feature

