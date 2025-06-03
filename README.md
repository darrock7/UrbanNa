# UrbanNa 

![CI](https://github.com/darrock7/UrbanNa/actions/workflows/flutter.yml/badge.svg)

## Our Goal 🎯

UrbanNa aims to simplify and accelerate the process of reporting and resolving urban infrastructure issues by creating a centralized platform where citizens can easily document problems while providing officials with the data needed to make informed decisions about resource allocation. Specifically, the system helps users identify and report issues like potholes, broken streetlights, fallen trees, and other urban infrastructure problems, track the status of their reports, and visualize problem patterns across their community.

## Technical Approach 💻
1. Frontend: A cross-platform framework (e.g., Flutter) in order to reach more users
2. Backend: Node.js with Express
3. Database: FIREBASE (NoSQL)

# Repo Format ℹ️
lib/
  models/
  providers/
  screens/
  views/
  widgets/
  helpers/
test/
.github/workflows/

We will have a few folders that will be designated to help maintain the structure of the app. This will include the providers, which will manage the state of the current app, the models folder to define the data structures shared across different components, and the helpers directory, which will contain utility functions and overall logic we need to develop. The screens folder will store the different user interface pages of the app like Home, Settings, Report Issue Screen while the views directory will include smaller, modular widgets used within those screens like the map display.

## Weekly Status Report 📄
Weekly Status Report can be found [here](https://docs.google.com/document/d/10sjFqyLY74quO8Lj4e5b28xgHaAJKX6YRBoEvSDAfjE/edit?usp=sharing)

## Version Control
When we commit we aim to have a clear description of what we changed and let the others know via messages. This allows all of us to check and examine what changed before commiting or pushing any other display. We want to create more branches as we continue to debug and improve our code, especially proceeding our development stage. This will be crucial as there are many elements we have left and many parts we want to continue to expand upon (e.g login, upvote, and photo inclusion).

## How to build and run system 🧰
### Prerequisites
- Flutter SDK >= 3.29.3
- Dart SDK >= 3.7.2
- Android Studio or XCode for emulators
- Git

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/darrock7/UrbanNa.git
   cd UrbanNa
2. Install dependencies:
   `flutter pub get `
3. Run and test the app:
   `flutter run`
This can be done through emulators with Android Studio and XCode or if a device is connected run Flutter run devices and select the right one.

More details on how to download the correct version of Flutter and emulators can be found on [flutter.dev](https://docs.flutter.dev/get-started/install?_gl=1*1xz7z94*_ga*MzQxMTYyMTU3LjE3NDU1MjcwMTQ.*_ga_04YGWK0175*czE3NDc3ODc2OTkkbzckZzAkdDE3NDc3ODc2OTkkajAkbDAkaDA.) after choosing the development platform and type of app you want use to build the app with.

## How to test system 🧪
We have included a Github actions CI which allows for the user to get the immediate dependacies and analyze the code. This is through the Flutter pub get, and Flutter analyze. This happens each time we pull or push into github. These commands can be independently done alongside Flutter test, which will run every test inside of our test folder. 

Using this we can confirm if the local database is storing the correct information and properly submitting. Having this test function helps tracks minor bugs that come, example could be minor such as the color not changing for the severity level.

## 

## Running Tests

To run tests locally, use the following command:

```bash
flutter test

