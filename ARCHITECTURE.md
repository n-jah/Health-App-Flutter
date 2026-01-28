# HealthTrack Architecture Guide

## System Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  UI Layer (Features)                                     │
│  ├── Permissions Screen                                  │
│  ├── Dashboard Screen                                    │
│  ├── Charts Screen                                       │
│  └── Settings Screen                                     │
├─────────────────────────────────────────────────────────┤
│  Service Layer                                           │
│  └── HealthService (Abstraction)                        │
├─────────────────────────────────────────────────────────┤
│  Core Layer                                              │
│  ├── Theme (Material 3)                                  │
│  ├── Models (Data structures)                           │
│  └── Utils (Helpers)                                     │
├─────────────────────────────────────────────────────────┤
│  External Dependencies                                   │
│  └── health package                                      │
├─────────────────────────────────────────────────────────┤
│  Platform Layer                                          │
│  ├── Android: Google Fit / Health Connect              │
│  └── iOS: HealthKit                                      │
└─────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. UI Layer (Features)

**Purpose**: User interface and user interaction

**Structure**:
```
features/
├── permissions/
│   └── permissions_screen.dart      # Onboarding & permission requests
├── dashboard/
│   ├── dashboard_screen.dart        # Main health summary
│   └── widgets/
│       ├── metric_card.dart         # Individual metric display
│       └── weekly_summary_card.dart # Weekly trend mini-chart
├── charts/
│   └── charts_screen.dart           # Detailed trend charts
└── settings/
    └── settings_screen.dart         # App configuration
```

**Responsibilities**:
- Render UI components
- Handle user interactions
- Manage local UI state with `setState`
- Call service layer for data
- Display loading/error states

**Key Patterns**:
- StatefulWidget for screens with state
- Custom reusable widgets
- Material 3 components
- Responsive layouts

### 2. Service Layer

**Purpose**: Business logic and data management

**File**: `services/health_service.dart`

**Responsibilities**:
- Abstract health platform APIs
- Fetch and aggregate health data
- Manage enabled/disabled metrics
- Handle permission requests
- Transform raw data into app models

**Key Methods**:
```dart
class HealthService {
  // Permission management
  Future<bool> requestPermissions()
  Future<bool> hasPermissions()
  
  // Data fetching
  Future<DailyHealthSummary> fetchDailySummary(DateTime date)
  Future<List<DailyHealthSummary>> fetchLast7Days()
  Future<List<HealthMetric>> fetchWeeklyMetrics(HealthDataCategory)
  
  // Settings
  void toggleDataType(HealthDataCategory, bool enabled)
  Map<HealthDataCategory, bool> get enabledTypes
}
```

**Design Decisions**:
- Single service class (not over-abstracted)
- Async/await for all data operations
- Error handling with try-catch
- Returns null for missing data (graceful degradation)

### 3. Core Layer

**Purpose**: Shared utilities and configurations

#### Theme (`core/theme/app_theme.dart`)
- Material 3 light and dark themes
- Consistent color palette
- Card and AppBar styling
- Reusable across all screens

#### Models (`core/models/`)

**health_data_type.dart**:
```dart
enum HealthDataCategory { steps, heartRate, calories, sleep }

class HealthDataTypeInfo {
  final HealthDataType type;      // health package type
  final String title;             // Display name
  final String unit;              // Measurement unit
  final IconData icon;            // Visual icon
  final Color color;              // Theme color
}
```

**health_metric.dart**:
```dart
class HealthMetric {
  final DateTime date;
  final double value;
  final String unit;
}

class DailyHealthSummary {
  final DateTime date;
  final int steps;
  final double? heartRate;
  final double? calories;
  final double? sleepHours;
}
```

#### Utils (`core/utils/date_utils.dart`)
- Date formatting helpers
- 7-day range generation
- Consistent date handling

### 4. External Dependencies

#### health package
- Provides unified API for Google Fit and HealthKit
- Handles platform-specific implementations
- Manages permissions at OS level

**Key Types Used**:
- `HealthDataType`: Enum of available metrics
- `HealthDataPoint`: Individual data point
- `NumericHealthValue`: Numeric measurement
- `HealthDataAccess`: Permission type (READ/WRITE)

## Data Flow

### Fetching Health Data

```
User Action (Pull to Refresh)
    ↓
Dashboard Screen
    ↓
HealthService.fetchLast7Days()
    ↓
For each day:
  HealthService.fetchDailySummary(date)
    ↓
  For each enabled metric:
    _fetchSteps() / _fetchHeartRate() / etc.
      ↓
    health.getHealthDataFromTypes()
      ↓
    Platform API (Google Fit / HealthKit)
      ↓
    Raw HealthDataPoint[]
      ↓
    Aggregate & Transform
      ↓
    Return DailyHealthSummary
    ↓
Update UI State
    ↓
Render Metric Cards
```

### Permission Flow

```
App Launch
    ↓
PermissionsScreen
    ↓
User taps "Grant Permissions"
    ↓
HealthService.requestPermissions()
    ↓
Get enabled data types
    ↓
health.requestAuthorization(types)
    ↓
Platform Permission Dialog
    ↓
User Grants/Denies
    ↓
Return bool result
    ↓
Navigate to Dashboard (if granted)
OR
Show error message (if denied)
```

## State Management Strategy

**Approach**: Simple `setState` (no complex state management)

**Rationale**:
- MVP scope doesn't require complex state
- Each screen manages its own state
- No shared state between screens
- Service layer is stateless (except settings)

**State per Screen**:
- **Dashboard**: `_todaySummary`, `_weeklySummaries`, `_isLoading`
- **Charts**: `_selectedCategory`, `_metrics`, `_isLoading`
- **Settings**: `_themeMode`, enabled types (in service)

## Error Handling Strategy

**Principles**:
1. **Graceful Degradation**: Show empty states, not crashes
2. **User-Friendly Messages**: Explain what went wrong
3. **Silent Failures**: Log errors, don't block UI
4. **Null Safety**: Use nullable types for optional data

**Implementation**:
```dart
try {
  final data = await _healthService.fetchData();
  setState(() => _data = data);
} catch (e) {
  print('Error: $e');  // Log for debugging
  // UI shows empty state automatically (data remains null)
}
```

## Extension Points

### Adding New Health Metrics

1. Add to `HealthDataCategory` enum
2. Create `HealthDataTypeInfo` constant
3. Add to `HealthDataTypeInfo.all` list
4. Implement fetch method in `HealthService`
5. UI automatically picks up new metric

### Adding New Screens

1. Create feature folder: `features/new_feature/`
2. Create screen widget
3. Add navigation in existing screens
4. Add to bottom navigation if needed

### Customizing Theme

1. Edit `core/theme/app_theme.dart`
2. Modify color palette constants
3. Update `lightTheme` and `darkTheme`
4. Changes apply app-wide automatically

## Performance Considerations

**Optimizations**:
- Fetch data only when needed (not on every build)
- Use `const` constructors where possible
- Lazy load chart data (only when Charts screen opened)
- Limit date range to 7 days
- Cache service instance (singleton pattern possible)

**Potential Improvements**:
- Add data caching layer
- Implement pagination for longer date ranges
- Use `compute()` for heavy data processing
- Add debouncing for refresh actions

## Testing Strategy

### Unit Tests (Recommended)
- `HealthService` methods
- Date utility functions
- Data model transformations

### Widget Tests (Recommended)
- Individual widgets (MetricCard, etc.)
- Screen layouts
- Navigation flows

### Integration Tests (Recommended)
- Full user flows
- Permission handling
- Data fetching and display

### Manual Testing (Required)
- Physical device testing (HealthKit requirement)
- Permission scenarios
- Theme switching
- Empty states

## Security & Privacy

**Considerations**:
- Health data never leaves device
- No backend or cloud storage
- Permissions requested explicitly
- User can disable individual metrics
- Follows platform privacy guidelines

**Platform Requirements**:
- Android: Declare permissions in manifest
- iOS: Provide usage descriptions
- Both: Request permissions at runtime

## Deployment Checklist

### Android
- [ ] Update `applicationId` in build.gradle
- [ ] Configure signing keys
- [ ] Test on multiple Android versions
- [ ] Verify Google Fit / Health Connect integration
- [ ] Test permission flows

### iOS
- [ ] Configure bundle identifier
- [ ] Add HealthKit capability in Xcode
- [ ] Test on physical device
- [ ] Verify HealthKit permissions
- [ ] Submit for App Store review (health apps require review)

## Maintenance Notes

**Regular Updates**:
- Keep `health` package updated
- Monitor Google Fit → Health Connect migration
- Update Material 3 components as Flutter evolves
- Test on new OS versions

**Known Technical Debt**:
- No data caching (fetch on every load)
- Simple error handling (could be more robust)
- No offline support
- Limited date range

**Future Architecture Considerations**:
- Consider state management library if app grows
- Add repository pattern for data layer
- Implement dependency injection
- Add analytics and crash reporting
