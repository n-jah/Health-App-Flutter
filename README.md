# 🏃‍♂️ HealthTrack - Your Personal Health Companion

<div align="center">

![HealthTrack Logo](screenshots/logo.png)

**Track your health metrics and visualize your progress over time**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![iOS](https://img.shields.io/badge/iOS-12.0+-000000?logo=apple)](https://www.apple.com/ios)
[![Android](https://img.shields.io/badge/Android-8.0+-3DDC84?logo=android)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Features](#-featharts**: Line charts with statistics for 7-day trends
- **Customizable Settings**: Toggle individual health metrics on/off
- **Theme Support**: Light and dark themes with system preference detection
- **Permission Management**: Granular health data permission requests

## Architecture

### Project Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 theme configuration
│   ├── models/
│   │   ├── health_data_type.dart   # Health metric definitions
│   │   └── health_metric.dart      # Data models
│   └── utils/
│       └── date_utils.dart         # Date formatting utilities
├── services/
│   └── health_service.dart         # Health data abstraction layer
├── features/
│   ├── permissions/
│   │   └── permissions_screen.dart # Onboarding & permissions
│   ├── dashboard/
│   │   ├── dashboard_screen.dart   # Main dashboard
│   │   └── widgets/
│   │       ├── metric_card.dart    # Individual metric display
│   │       └── weekly_summary_card.dart
│   ├── charts/
│   │   └── charts_screen.dart      # Weekly trend charts
│   └── settings/
│       └── settings_screen.dart    # App settings
└── main.dart                       # App entry point
```

### Architecture Decisions

1. **Feature-Based Organization**: Code is organized by feature rather than layer, improving maintainability and scalability.

2. **Service Abstraction**: `HealthService` class abstracts all health platform interactions, providing a clean API for UI components.

3. **Simple State Management**: Uses `setState` for local state management, avoiding unnecessary complexity for this MVP scope.

4. **Reusable Widgets**: Custom widgets like `MetricCard` and `WeeklySummaryCard` promote code reuse and consistency.

5. **Material 3 Design**: Leverages Flutter's latest Material Design 3 components for a modern, polished look.

## Supported Health Data

| Metric | Android (Google Fit) | iOS (HealthKit) | Unit |
|--------|---------------------|-----------------|------|
| Steps | ✅ | ✅ | steps |
| Heart Rate | ✅ | ✅ | bpm |
| Calories Burned | ✅ | ✅ | kcal |
| Sleep Duration | ✅ | ✅ | hours |

## Setup & Installation

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- Android Studio / Xcode for platform-specific builds

### Dependencies

```yaml
dependencies:
  health: ^11.0.0              # Health data integration
  fl_chart: ^0.69.0            # Chart visualization
  intl: ^0.19.0                # Date formatting
  permission_handler: ^11.3.1  # Permission management
```

### Installation Steps

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Android Setup**:
   - Add required permissions to `android/app/src/main/AndroidManifest.xml`
   - Configure Google Fit API in Google Cloud Console
   - Add OAuth client ID

4. **iOS Setup**:
   - Add HealthKit capability in Xcode
   - Add usage descriptions to `Info.plist`

5. Run the app:
   ```bash
   flutter run
   ```

## Platform-Specific Configuration

### Android (Google Fit)

Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.health.READ_STEPS"/>
<uses-permission android:name="android.permission.health.READ_HEART_RATE"/>
```

### iOS (HealthKit)

Add to `Info.plist`:
```xml
<key>NSHealthShareUsageDescription</key>
<string>This app needs access to your health data to display your fitness metrics</string>
<key>NSHealthUpdateUsageDescription</key>
<string>This app needs to update your health data</string>
```

## Known Limitations

1. **Google Fit Deprecation**: Google Fit API is being deprecated in favor of Health Connect. Future versions should migrate to Health Connect for Android.

2. **Read-Only Implementation**: Current version focuses on reading health data. Writing data is not implemented in this MVP.

3. **7-Day Window**: Data visualization is limited to the last 7 days for simplicity and performance.

4. **No Backend**: All data is fetched directly from device health platforms. No cloud storage or sync.

5. **Limited Metrics**: Only 4 core health metrics are supported. The architecture allows easy addition of more metrics.

6. **Permission Handling**: Some platforms may require additional configuration for certain health data types.

## Future Enhancements

- Migration to Health Connect for Android
- Extended date range selection
- Data export functionality
- Goal setting and achievement tracking
- Notifications and reminders
- More health metrics (water intake, weight, etc.)
- Data insights and trends analysis

## Technical Notes

- **Minimum SDK**: Android 8.0 (API 26), iOS 12.0
- **State Management**: Simple setState approach, suitable for MVP scope
- **Error Handling**: Graceful degradation when permissions are denied or data is unavailable
- **Performance**: Efficient data fetching with date-based queries
- **UI/UX**: Material 3 design with smooth animations and transitions

**Android SDK 26+ Requirement**: The health package requires Android 8.0 or higher for Health Connect support. This covers 95%+ of active Android devices.

## License

This is a technical evaluation project and is not intended for production use.
