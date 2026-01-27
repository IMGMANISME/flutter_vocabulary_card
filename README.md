# Gocab

**Gocab** is an English vocabulary learning application designed to help users master C1 CEFR vocabulary words. It features a responsive flashcard interface, real-time Firestore synchronization, and "Hide Learned" functionality.

## Features

-   **Flashcard Interface**: Interactive flashcards with flip animations.
-   **Responsive Layout**: Optimized for various screen sizes, with auto-scaling text.
-   **Learned Status**: Mark words as "Learned" to filter them out of your study session.
-   **Real-time Sync**:
    -   **Logged In**: Syncs learned status across devices using Firebase Firestore.
    -   **Logged Out**: Saves progress locally on the device.
-   **Google Sign-In**: Secure authentication with Google.
-   **Letter Navigation**: Quickly jump to words starting with a specific letter.

## Tech Stack & Architecture

This project follows **Clean Architecture** principles and uses **Riverpod** for state management.

-   **Architecture**: Feature-First Clean Architecture (Domain, Data, Presentation layers)
-   **Frontend**: Flutter (Dart)
-   **State Management**: Riverpod (v2+ with code generation)
-   **Backend**: Firebase (Firestore, Authentication)
-   **Code Generation**: `build_runner`, `riverpod_generator`, `json_serializable`, `freezed`

## Setup & Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/flutter_vocabulary_card.git
    cd flutter_vocabulary_card
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run Code Generation** (Required for Riverpod & Models):
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Firebase Configuration**:
    -   Ensure you have `firebase_options.dart` configured for your Firebase project.
    -   (If not set up) Use `flutterfire configure` to generate the file.

5.  **Run the App**:
    -   **iOS**: Open `ios/Runner.xcworkspace` in Xcode to configure signing, then run:
        ```bash
        flutter run
        ```
    -   **Android**:
        ```bash
        flutter run
        ```

## Deployment to Physical Device (iOS)

To run on a physical iPhone/iPad:

1.  Open `ios/Runner.xcworkspace` in Xcode.
2.  Go to **Signing & Capabilities**.
3.  Select your **Team** (Apple ID).
4.  Connect your device and trust the computer.
5.  Run the app via Xcode or `flutter run -d <device-id>`.

## License

This project is licensed under the MIT License.
