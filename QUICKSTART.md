# Quick Start Guide

## 1. Environment Setup

### Prerequisites Check
- ✅ Flutter SDK installed (3.0+)
- ✅ Dart SDK installed (3.0+)
- ✅ Android emulator or iOS simulator ready
- ✅ Backend API running (PHP/MySQL)

### Install Dependencies
```bash
flutter pub get
```

## 2. Database Setup

The app uses a backend API (PHP) with a MySQL database. Ensure your API is running and reachable from the device/emulator.

- Users table with authentication integration
- Traffic signs catalog
- Quiz questions and answers
- User progress tracking
- Exam attempts and results
- Badges system

All tables have Row Level Security (RLS) policies configured.

## 3. Running the App

### Development Mode
```bash
flutter run
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

## 4. Key File Locations

- **Main Entry**: `lib/main.dart`
- **Theme Config**: `lib/config/theme/`
- **Router**: `lib/config/router/app_router.dart`
- **Authentication**: `lib/features/auth/`
- **Pages**: `lib/features/*/presentation/pages/`

## 5. Authentication Flow

### Register
1. Go to Landing Page
2. Click "Create Account" or navigate to `/register`
3. Enter full name, email, and password
4. Accept terms and create account
5. Automatically logged in and redirected to home

### Login
1. Click "Login" on landing page
2. Enter email and password
3. Toggle "Remember me" for auto-login
4. Redirected to dashboard

### Password Reset
1. Click "Forgot password?" on login page
2. Enter email address
3. Check email for reset link
4. Follow email link to reset password

## 6. Navigation Structure

```
Landing (/landing)
├── Login (/login)
│   └── Forgot Password (/forgot-password)
├── Register (/register)
└── Dashboard (Protected - requires auth)
    ├── Home (/home)
    ├── Signs (/signs)
    │   └── Sign Detail (/signs/:signId)
    ├── Practice (/practice)
    │   └── Quiz (/practice/quiz/:categoryId)
    ├── Exam (/exam)
    │   ├── Intro (/exam)
    │   ├── Exam (/exam/start)
    │   └── Results (/exam/result/:attemptId)
    ├── Progress (/progress)
    ├── Profile (/profile)
    └── Settings (/settings)
```

## 7. Testing Features

### Test User Account
```
Email: test@example.com
Password: password123
```

Create your own account through the register page.

### Test Quiz
1. Home page → Start Mock Test
2. Complete all 20 questions
3. View results and badge

### Test Signs Learning
1. Navigate to Signs tab
2. Browse and filter traffic signs
3. View sign details
4. Mark signs as learned

## 8. Customization

### Change Color Theme
Edit `lib/config/theme/app_colors.dart`:
```dart
static const Color primary = Color(0xFF1E3A8A); // Deep Blue
static const Color accent = Color(0xFFF97316);  // Traffic Orange
```

### Modify Questions
Edit quiz data in respective page files:
- Practice Exams: `lib/features/practice/presentation/pages/quiz_page.dart`
- Mock exam: `lib/features/exam/presentation/pages/exam_page.dart`

### Add Traffic Signs
Insert into Supabase `traffic_signs` table:
```sql
INSERT INTO traffic_signs (title, description, category, scenario)
VALUES ('Sign Name', 'Description', 'Warning', 'Real-life example');
```

## 9. Build for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS Build (for App Store)
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web --release
```

## 10. Debugging Tips

### Common Issues

**"Flutter command not found"**
- Add Flutter to PATH
- Restart terminal/IDE

**"Gradle failed"**
```bash
flutter clean
flutter pub get
```

**"API connection error"**
- Ensure the device can reach your API host (don’t use `localhost` on a real phone)
- Confirm your API base URL is correct
- Verify the API is listening on `0.0.0.0` (not `127.0.0.1`) and the firewall allows the port

**"Widget not found"**
- Run `flutter pub get`
- Rebuild with `flutter clean`

## 11. Performance Optimization

- App uses lazy loading for images
- BLoC efficiently manages state
- Bottom navigation uses efficient shell routing

## 12. Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern Guide](https://bloclibrary.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## Next Steps

1. **Customize Content**: Add your traffic signs and questions
2. **Configure Branding**: Update colors and logos
3. **Add More Languages**: Implement localization
4. **Connect Analytics**: Track user behavior
5. **Set Up Push Notifications**: Remind users daily
6. **Deploy to App Stores**: Publish to Play Store/App Store

---

**Happy learning! Master those traffic rules! 🚗✨**
