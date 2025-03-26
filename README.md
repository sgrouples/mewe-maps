# MeWe Maps

## Project Status: 🚧 In Development 🚧

## Setup Instructions

This project uses environment secrets, as well as Firebase and Google Services configuration files, which are excluded from Git:

```sh
.env
/lib/services/firebase/firebase_options.dart
/android/app/google-services.json
/ios/Runner/GoogleService-Info.plist
/firebase.json
/.firebaserc
```

Contact the owners if you want to build the app.

Additionally, before building the app, you need to generate `g.dart` files by executing:

```sh
flutter pub run build_runner build
```

## Deploying Firebase Functions

This project includes Firebase Cloud Functions located in the `functions` directory. To deploy them, follow these steps:

#### 1. Install Firebase CLI (if not already installed):
```sh
npm install -g firebase-tools
```
#### 2. Login to Firebase:
```sh
firebase login
```
#### 3. Link the project to Firebase (if not already linked):
```sh
firebase use --add
```
#### 4. Install Firebase Functions Dependencies:
```sh
cd functions
npm install
```
#### 5. Deploy Firebase Functions:
```sh
firebase deploy --only functions
```

## Code Style
Before pushing anything to the default branch, format the code with:

```sh
dart format . --line-length 160
```

## License
```text
Copyright MeWe 2025.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.
```
