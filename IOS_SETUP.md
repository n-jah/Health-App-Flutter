# iOS Setup Guide for HealthTrack

## Prerequisites

- iOS 12.0 or later
- Physical iOS device (HealthKit doesn't work on simulator)
- Apple Health app (pre-installed on all iPhones)

## iOS Configuration

The app is already configured with:
- ✅ HealthKit permissions in Info.plist
- ✅ HealthKit entitlements
- ✅ Health data type access

## How to Use on iOS

### 1. Build and Install
```bash
flutter run -d <your-iphone-device-id>
```

Or open in Xcode:
```bash
open ios/Runner.xcworkspace
```

### 2. Enable HealthKit in Xcode (Important!)

If building from Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "HealthKit"
6. Make sure it's enabled

### 3. Grant Permissions

When you first open the app:
1. Tap "Grant Permissions"
2. iOS will show the Health app permission dialog
3. Enable all requested permissions:
   - ✅ Steps
   - ✅ Heart Rate
   - ✅ Active Energy (Calories)
   - ✅ Sleep Analysis

### 4. Verify Health Data Exists

Open the Apple Health app and check:
- **Steps:** Should show today's steps
- **Heart Rate:** Requires Apple Watch or manual entry
- **Active Energy:** Requires Apple Watch or fitness apps
- **Sleep:** Requires Apple Watch or sleep tracking apps

### 5. Test the App

1. Walk around to generate steps
2. Open HealthTrack
3. Pull down to refresh
4. Your steps should appear!

## Troubleshooting iOS

### No Data Appears?

**Check 1: Permissions**
- Settings → Privacy & Security → Health → HealthTrack
- Make sure all data types are enabled

**Check 2: Health App Has Data**
- Open Apple Health app
- Check if you have steps for today
- If not, walk around or manually add data

**Check 3: App Permissions**
- Open HealthTrack → Settings → Grant Permissions
- Re-grant permissions if needed

**Check 4: HealthKit Capability**
- Open project in Xcode
- Check "Signing & Capabilities"
- HealthKit should be listed

### Common iOS Issues

**1. "HealthKit not available"**
- You're using iOS Simulator (not supported)
- Solution: Use a real iPhone

**2. "No permissions"**
- Permissions not granted in Health app
- Solution: Settings → Health → HealthTrack → Enable all

**3. "No data"**
- Apple Health has no data
- Solution: Walk around or use Apple Watch

**4. "Build error: HealthKit capability"**
- Xcode project not configured
- Solution: Add HealthKit capability in Xcode

## iOS vs Android Differences

| Feature | iOS | Android |
|---------|-----|---------|
| Data Source | Apple Health (built-in) | Health Connect (install required) |
| Simulator | ❌ Not supported | ✅ Works with demo data |
| Setup | Automatic | Requires Health Connect install |
| Permissions | Per data type | Per data type |
| Background Sync | ✅ Automatic | ✅ Automatic |

## iOS-Specific Features

### Apple Health Integration
- Reads directly from Apple Health
- No additional apps needed
- Syncs with Apple Watch automatically
- Works with all Health-compatible apps

### Data Types Available
- ✅ Steps (iPhone built-in)
- ✅ Heart Rate (Apple Watch required)
- ✅ Active Energy (Apple Watch or fitness apps)
- ✅ Sleep (Apple Watch or sleep apps)

### Privacy
- iOS shows exactly what data is accessed
- You can revoke permissions anytime
- Data never leaves your device

## Testing on iOS

### Quick Test:
1. Open Apple Health app
2. Tap "Browse" → "Activity" → "Steps"
3. Verify you have steps for today
4. Open HealthTrack
5. Grant permissions when prompted
6. Steps should appear immediately

### Manual Data Entry (for testing):
1. Open Apple Health
2. Tap "Browse" → "Activity" → "Steps"
3. Tap "Add Data" (top right)
4. Enter steps manually
5. Open HealthTrack to see the data

## Building for iOS

### Development Build:
```bash
flutter run -d <device-id>
```

### Release Build:
```bash
flutter build ios --release
```

Then open in Xcode and archive for App Store.

## App Store Submission

When submitting to App Store, make sure:
1. HealthKit capability is enabled
2. Privacy descriptions are clear
3. App uses health data appropriately
4. Screenshots show health features

Apple will review your health data usage.

## Minimum iOS Version

The app requires iOS 12.0 or later because:
- HealthKit API compatibility
- Flutter minimum requirements
- Modern Swift features

## Need Help?

If data still doesn't appear on iOS:
1. Check Xcode console for error messages
2. Verify HealthKit capability is enabled
3. Confirm you're using a real device (not simulator)
4. Check Apple Health app has data
5. Re-grant permissions in Settings
