## ABOUT PROJECT
Peanut Budget is a mobile app to help users manage their expenditure and budget. It is built in Flutter and uses Dart as its primary language.\
<br/>

## PROJECT STRUCTURE
`lib/` is where all the main source code lives, as `.dart` files.\
- `models/entry.dart` contains the data class for entries
- `screens/dashboard.dart` is the homepage, with buttons for adding entries and a summary of the week/month so far
- `screens/history.dart` is the second page, with a log of all past entries that can be filtered by category, date range, amount etc
- `widgets/add_entry_modal.dart` is the modal window for adding entries
<br/>

## USAGE
To preview the app live, do `flutter run` in your terminal and select the appropriate device. For help with Android setup, see below.\
<br/>

## SETUP GUIDE
This section documents the steps I took in setting up the development environment on Windows for my Flutter project. I only developed for Android, so the steps for iOS support are not included here.\
<br/>

**Prerequisites: Have VSCode and Git installed on your system**
### Step 1: Install Flutter
Add the Flutter extension by Dart Code to VSCode. This also installs the Dart extension.\
Open the command palette (CTRL + SHIFT + P) and select Flutter: New Project. Download the Flutter SDK when prompted, and click Clone Flutter in your desired folder.\
Once done, add the SDK to your PATH variable.
### Step 2: Set up Android environment
From the Oracle downloads page, download and install JDK 17 or JDK 21.\
From the Android downloads page, scroll to the bottom and find Command Line Tools only. Download and unzip the package.\
Navigate to `cmdline-tools/` and create a new folder `latest/`. Move the entire contents of `cmdline-tools` into the folder. Your structure should now look like `cmdline-tools/latest/everything`.\
Then, run the sdkmanager to download the Android SDK.
```bash
.\latest\bin\sdkmanager.bat "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```
**NOTE:** The versions you require may be different. Run `flutter doctor` in your terminal to check that Flutter has registered a valid Android SDK. You may need to point Flutter at your Android SDK installation folder with `flutter config --android-sdk path\to\sdk-folder`.\
Finally, add `platform-tools/` to your PATH variable.
### Step 3: Verify all your installations
You should have Flutter, JDK, and ADB accessible from your terminal. Run to check:
```bash
flutter --version
java -version
adb --version
```
### Step 4: Live preview your app
First, connect both your Android device and computer to the same WiFi network.\
On your Android device, go to "Developer options". If not enabled, do so by going to Settings > About Phone > Software information and tapping "Build number" 7 times.\
In Developer options, enable "Wireless debugging". Click "Pair device with pairing code". Now pair your phone with your computer, using the provided IP address and port in the popup:
```bash
adb pair <IP-address>:<port>
# Enter the 6-digit code when prompted
```
Next, connect your devices. Use the actual IP address and port of your phone, NOT the one you just used for pairing. This is visible under "Device name" on the Wireless debugging screen.
```bash
adb connect <IP-address>:<port>
```
Now run your app:
```bash
flutter run
# Select your phone as a device when prompted
```
You should see it appear on your phone screen.\
<br/>