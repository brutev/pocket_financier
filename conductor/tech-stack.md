# Technology Stack

## 1. Programming Language & Framework
- **Language:** Dart
- **Framework:** Flutter
  - This project is built using the Flutter framework for cross-platform mobile app development.

## 2. Database
- **Database:** SQLite
- **Package:** `sqflite`
  - A local SQLite database is used for on-device data storage, ensuring user privacy and offline functionality.

## 3. Core Libraries & Packages
- **State Management & UI:**
  - `flutter`: The core Flutter SDK.
  - `fl_chart`: Used for creating interactive and visual financial charts.
- **Device & OS Interaction:**
  - `flutter_sms_inbox`: For reading SMS messages from the user's inbox (Android only).
  - `permission_handler`: To manage runtime permissions, specifically for SMS access.
  - `path_provider`: To locate the filesystem path for the local database.
- **AI & Machine Learning:**
  - `flutter_gemma`: Integrates with on-device AI models for features like the Financial Coach.
- **Utilities:**
  - `flutter_dotenv`: Manages environment variables and configuration.
  - `path`: For platform-agnostic path manipulation.

## 4. Development & Testing
- **Testing:** `flutter_test` for unit and widget testing.
- **Linting:** `flutter_lints` to enforce code style and quality.
