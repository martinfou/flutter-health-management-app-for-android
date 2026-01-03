# Deployment Guide

## Overview

This guide provides step-by-step instructions for building, signing, and deploying the Flutter Health Management App for Android to the Google Play Store.

**Target Platform**: Android  
**Distribution**: Google Play Store  
**Build Type**: Release APK/AAB

## Prerequisites

### Required Tools

- Flutter SDK (latest stable version)
- Android Studio
- Java Development Kit (JDK) 8 or higher
- Android SDK (API Level 24-34)
- Google Play Console account
- App signing key

### Required Accounts

- Google Play Console developer account
- Google Play Console app listing created

## Build Configuration

### Release Build Setup

**1. Configure App Version**:

Update `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: major.minor.patch+buildNumber
```

Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        versionCode 1
        versionName "1.0.0"
    }
}
```

**2. Configure App Signing**:

Create keystore file:
```bash
keytool -genkey -v -keystore ~/health-app-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias health-app
```

Create `android/key.properties`:
```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=health-app
storeFile=<path-to-keystore>/health-app-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**3. Configure ProGuard Rules**:

Create `android/app/proguard-rules.pro`:
```proguard
# Hive
-keep class * extends io.flutter.plugins.hive.HiveObject { *; }
-keep @hive.HiveType class * { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```

## Build Process

### Build Android App Bundle (AAB)

**Recommended for Play Store**:
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (Alternative)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build Split APKs (Optional)

For smaller download sizes:
```bash
flutter build apk --split-per-abi --release
```

Outputs separate APKs for each architecture (arm64-v8a, armeabi-v7a, x86_64)

## Pre-Deployment Testing

### Testing Checklist

- [ ] Test on multiple Android versions (7.0-14)
- [ ] Test on different screen sizes
- [ ] Test all core features
- [ ] Verify no crashes or errors
- [ ] Test data persistence
- [ ] Test offline functionality
- [ ] Verify performance benchmarks met
- [ ] Test on low-end devices
- [ ] Verify all permissions work correctly
- [ ] Test notification functionality

### Internal Testing

**1. Internal Testing Track**:
- Upload AAB to Play Console Internal Testing track
- Add testers via email
- Test on real devices
- Collect feedback

**2. Closed Testing Track**:
- Upload AAB to Closed Testing track
- Add testers via email or Google Groups
- Larger testing group
- Collect feedback and bug reports

## Play Store Submission

### 1. Create App Listing

**Required Information**:
- App name
- Short description (80 characters)
- Full description (4000 characters)
- Screenshots (at least 2, up to 8)
- Feature graphic (1024x500)
- App icon (512x512)
- Privacy policy URL

### 2. Content Rating

- Complete content rating questionnaire
- Answer all health/medical data questions
- Submit for rating

### 3. Set Up Pricing and Distribution

- Set app as Free or Paid
- Select countries for distribution
- Set age restrictions if needed

### 4. Complete Store Listing

**Screenshots**:
- Phone screenshots (at least 2): 16:9 or 9:16
- Tablet screenshots (optional): Any ratio
- Feature graphic: 1024x500

**Description**:
- Highlight key features
- Include benefits
- Clear, concise language

### 5. Upload Release

**1. Go to Production track**:
- Click "Create new release"
- Upload AAB file
- Enter release notes

**2. Release Notes**:
- What's new in this version
- Bug fixes
- Improvements
- Feature additions

**3. Review and Release**:
- Review all information
- Submit for review
- Wait for Google Play review (1-7 days)

## Release Management

### Version Management

**Version Numbering**:
- Major.Minor.Patch (e.g., 1.0.0)
- Version code: Incrementing integer (1, 2, 3, ...)

**Version Update Process**:
1. Update version in `pubspec.yaml`
2. Update version in `build.gradle`
3. Build new release
4. Upload to Play Console
5. Add release notes
6. Submit for review

### Staged Rollouts

**Gradual Rollout**:
- Start with 20% of users
- Monitor crash reports and ratings
- Gradually increase to 100%
- Roll back if issues found

**Rollout Steps**:
1. Initial release: 20%
2. Monitor for 24-48 hours
3. Increase to 50% if no issues
4. Monitor for 24-48 hours
5. Increase to 100% if no issues

## Post-Deployment Monitoring

### Monitor Metrics

**Key Metrics**:
- Crash rate
- ANR (Application Not Responding) rate
- User ratings and reviews
- Installation numbers
- Uninstall rate

### Crash Reporting

**Tools**:
- Firebase Crashlytics (recommended)
- Google Play Console crash reports
- Custom crash reporting

**Actions**:
- Monitor crash reports daily
- Fix critical crashes immediately
- Update app with fixes
- Communicate with users via Play Console

### User Feedback

**Monitor Reviews**:
- Respond to user reviews
- Address common complaints
- Thank positive reviews
- Update app based on feedback

## Troubleshooting

### Common Issues

**Build Failures**:
- Check Flutter and Android SDK versions
- Clean build: `flutter clean`
- Verify keystore configuration
- Check ProGuard rules

**Play Console Issues**:
- Verify AAB format
- Check signing configuration
- Verify app bundle size limits
- Check content rating completion

**App Rejection**:
- Address Google Play review feedback
- Update privacy policy if needed
- Fix policy violations
- Resubmit after fixes

## Security Considerations

### Key Management

- **Never commit** `key.properties` to version control
- Store keystore file securely
- Backup keystore file (losing it prevents updates)
- Use strong passwords for keystore

### App Security

- Enable code obfuscation
- Enable resource shrinking
- Review ProGuard rules
- Test obfuscated build

## Continuous Deployment (Future)

### GitHub Actions

Automate build and deployment:
- Build AAB on release tag
- Upload to Play Console
- Automatic version bumping
- Release notes generation

## References

- **Flutter Build Docs**: https://docs.flutter.dev/deployment/android
- **Google Play Console**: https://play.google.com/console
- **App Signing**: https://developer.android.com/studio/publish/app-signing

---

**Last Updated**: [Date]  
**Version**: 1.0  
**Status**: Deployment Guide Complete

