# Traffic Rules Learning & Practice App

A professional, modern Flutter application for learning traffic rules and preparing for provisional driving license exams.

## Overview

Master Traffic Rules is a comprehensive mobile and web application designed to help aspiring drivers prepare for their driving license exams. The app combines interactive learning, practice quizzes, and mock exams with engaging gamification elements to make exam preparation rewarding and effective.

## Features

### 🎓 Core Features

- **Landing Page**: Clean hero section with app overview and CTA buttons
- **Authentication**: Secure email/password registration and login
  - Sign up with full name
  - Remember me functionality
  - Forgot password recovery
  - Password validation

- **Home Dashboard**:
  - Time-based greeting (Good Morning/Afternoon/Evening)
  - Progress indicator showing overall completion
  - Last mock exam score display
  - Daily streak tracker
  - Quick action buttons for:
    - Start Mock Test
    - Learn Traffic Signs
    - Practice Quiz

- **Traffic Signs Module**:
  - Browse comprehensive traffic sign database
  - Filter by category (Warning, Regulatory, Informational)
  - Search functionality
  - Detailed sign information with real-life scenarios
  - Mark signs as learned to track progress

- **Practice Quiz System**:
  - Category-based practice questions
  - Multiple choice format (4 options)
  - Immediate feedback (correct/incorrect)
  - Explanation for each answer
  - Progress tracking
  - Score calculation and results

- **Mock Exam**:
  - Timed exam experience (30 minutes)
  - 20 questions covering all categories
  - Real exam simulation
  - No revisiting previous questions
  - Detailed result screen with:
    - Final score and percentage
    - Pass/Fail badge
    - Category-wise accuracy
    - Option to retake or review

- **Progress Tracking**:
  - Overall progress overview
  - Performance statistics
  - Last 5 exam scores graph
  - Category-wise accuracy breakdown
  - Weak areas identification
  - Best score tracking

- **User Profile**:
  - Avatar with user initial
  - Name and email display
  - Statistics summary (tests, signs learned, current score)
  - Earned badges showcase
  - Edit profile capability

- **Settings**:
  - Dark mode toggle
  - Notification preferences
  - Language selector
  - Reset progress option
  - Privacy policy and terms of service links
  - Logout

### 🎮 Gamification

- **Daily Streak**: Track consecutive days of practice
- **Badges System**:
  - First Test badge
  - Perfect Score badge
  - Speed Master badge
  - Week Streak badge
  - Sign Expert badge
- **Progress Visualization**: Circular and linear progress indicators
- **Motivational Messages**: Contextual feedback based on performance
- **Achievement Celebrations**: Special screens for milestones

## Design System

### Color Palette

- **Primary**: Deep Blue (#1E3A8A)
- **Accent**: Traffic Orange (#F97316)
- **Success**: Green (#16A34A)
- **Error**: Red (#DC2626)
- **Warning**: Yellow (#F59E0B)
- **Background**: Light Gray (#F3F4F6)
- **Neutral Tones**: Complete gray scale from #111827 to #F3F4F6

### Typography

- **Font Family**: Google Fonts - Poppins
- **Headings**: Bold, modern sans-serif (sizes 16-40px)
- **Body**: Clean readable sans-serif (sizes 12-16px)
- **Line Height**: 1.5 for body, 1.2-1.4 for headings

### Components

- **Rounded Corners**: 16px radius throughout
- **Shadow System**: Soft, subtle shadows (8px blur, 8px offset)
- **Input Fields**: Floating labels, smooth validation states
- **Buttons**: Multiple variants (primary, secondary, outline, icon)
- **Cards**: Consistent border and shadow styling
- **Bottom Navigation**: Fixed, persistent navigation bar

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/
│   ├── router/
│   │   └── app_router.dart           # GoRouter configuration
│   └── theme/
│       ├── app_colors.dart           # Color palette
│       ├── app_text_styles.dart      # Typography
│       └── app_theme.dart            # Theme configuration
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── landing_page.dart
│   │           ├── login_page.dart
│   │           ├── register_page.dart
│   │           └── forgot_password_page.dart
│   ├── home/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── home_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── home_page.dart
│   │           └── main_layout.dart
│   ├── signs/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── sign_model.dart
│   │   │   └── repositories/
│   │   │       └── signs_repository.dart
│   │   └── presentation/
│   │       └── pages/
│   │           ├── signs_page.dart
│   │           └── sign_detail_page.dart
│   ├── practice/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── practice_page.dart
│   │           └── quiz_page.dart
│   ├── exam/
│   │   └── presentation/
│   │       └── pages/
│   │           ├── exam_intro_page.dart
│   │           ├── exam_page.dart
│   │           └── exam_result_page.dart
│   ├── progress/
│   │   └── presentation/
│   │       └── pages/
│   │           └── progress_page.dart
│   ├── profile/
│   │   └── presentation/
│   │       └── pages/
│   │           └── profile_page.dart
│   └── settings/
│       └── presentation/
│           └── pages/
│               └── settings_page.dart
└── shared/                            # Shared utilities (future expansion)
```

## Database Schema

### Tables

- **users**: User profiles and statistics
- **traffic_signs**: Comprehensive traffic sign database
- **categories**: Quiz categories
- **questions**: Quiz questions
- **answers**: Answer options
- **user_progress**: Learned signs tracking
- **exam_attempts**: Exam session records
- **user_answers**: Individual exam answers
- **badges**: Achievement badges
- **user_badges**: User earned badges

### Security

- **Row Level Security (RLS)**: Enabled on all tables
- **Access Control**: Users can only access their own data
- **Public Data**: Traffic signs and questions publicly readable
- **Policies**: Restrictive by default, specific auth checks

## State Management

- **BLoC Pattern**: Flutter BLoC for state management
- **Event-Driven Architecture**: Clear event handling
- **Separation of Concerns**: Data, domain, and presentation layers

## Navigation

- **GoRouter**: Type-safe routing with deep linking
- **Shell Routes**: Nested navigation for bottom navigation bar
- **Protected Routes**: Automatic redirects based on auth state
- **Named Routes**: Easy reference and navigation

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android SDK / iOS SDK (for mobile development)
- A running backend API (PHP/MySQL) reachable from your device

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**Web:**
```bash
flutter build web --release
```

**iOS:**
```bash
flutter build ios --release
```

## Key Dependencies

- **flutter_bloc** (9.0.0): State management
- **go_router** (13.2.0): Navigation
- **http** (1.1.0): Backend API integration
- **google_fonts** (6.1.0): Typography
- **fl_chart** (0.68.0): Data visualization
- **cached_network_image** (3.3.0): Image caching
- **shared_preferences** (2.2.0): Local storage
- **intl** (0.19.0): Internationalization
- **provider** (6.1.0): Locale state management
- **flutter_localizations**: Material/Cupertino locale delegates

## Multilanguage / Localization (i18n)

The app supports **English (en)**, **French (fr)**, and **Kinyarwanda (rw)** with full runtime switching.

### Setup

After cloning or pulling, run:

```bash
flutter pub get
flutter gen-l10n
```

This generates the localization classes in `lib/l10n/generated/`.

### How It Works

| Component | File | Purpose |
|-----------|------|---------|
| ARB files | `lib/l10n/intl_en.arb`, `intl_fr.arb`, `intl_rw.arb` | Translation strings (ICU message format) |
| gen-l10n config | `l10n.yaml` | Tells Flutter where ARB files live and where to output generated code |
| Locale provider | `lib/shared/locale/locale_provider.dart` | `ChangeNotifier` that loads/saves locale via `SharedPreferences` |
| Language selector | `lib/shared/locale/language_selector_page.dart` | Full-screen first-run selector + reusable dialog for Settings |
| Generated code | `lib/l10n/generated/app_localizations.dart` | Auto-generated `AppLocalizations` class (after running `flutter gen-l10n`) |

### Using Translated Strings

```dart
import 'package:traffic_rules_app/l10n/generated/app_localizations.dart';

// In a widget's build method:
final l10n = AppLocalizations.of(context)!;
Text(l10n.homeWelcomeBack);           // Simple string
Text(l10n.homeGreeting('Jean'));       // Interpolation
Text(l10n.homePracticeSessions(5));    // Plural (ICU)
```

### Adding a New Language

1. Create `lib/l10n/intl_XX.arb` (where `XX` is the ISO language code) — copy `intl_en.arb` as a template and translate all values.
2. Add `Locale('XX')` to `LocaleProvider.supportedLocales` in `lib/shared/locale/locale_provider.dart`.
3. Add the language name to `LocaleProvider.localeNames` (e.g., `'XX': 'LanguageName'`).
4. Add a flag emoji case in `_LanguageCard._flagEmoji()` in `lib/shared/locale/language_selector_page.dart`.
5. Run `flutter gen-l10n` to regenerate.

### Running Locale Tests

```bash
flutter test test/locale_widget_test.dart
```

Tests verify:
- First-run shows the language selector when no locale is persisted.
- Selecting a language persists the choice in `SharedPreferences`.
- Changing language at runtime updates the provider's locale immediately.

## Architecture Highlights

### Clean Architecture
- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Injection**: Repositories injected into BLoCs
- **Testing Ready**: Mockable repositories and services

### Responsive Design
- **Mobile First**: Optimized for mobile devices
- **Web Support**: Responsive layouts for larger screens
- **Breakpoints**: Adapted layouts at 768px width

### Performance
- **Lazy Loading**: Images and data loaded on demand
- **Efficient Queries**: Optimized Supabase queries
- **Local Caching**: Reduced network requests

### UX/UI
- **Micro-interactions**: Smooth transitions and animations
- **Loading States**: Clear feedback during operations
- **Error Handling**: User-friendly error messages
- **Accessibility**: High contrast colors (WCAG compliant)

## Future Enhancements

- Offline mode support
- Push notifications
- Social leaderboard
- Video tutorials
- Voice-based learning
- AI-powered recommendations
- Advanced analytics
- Export/certificate generation
- Multiple language support (in-app)
- Adaptive difficulty levels

## Development Notes

### Code Conventions
- Follow Dart style guide
- Use meaningful variable and function names
- Keep functions small and focused
- Document complex logic

### Testing
- Write unit tests for business logic
- Create widget tests for UI components
- Test authentication flows
- Validate form inputs

### Deployment
- Test on multiple devices
- Verify responsive design
- Check internet connectivity handling
- Monitor app performance
- Set up crash reporting

## Support & Contribution

For issues, feature requests, or contributions, please follow the standard Git workflow:

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Wait for review and approval

## License

This project is licensed under the MIT License.

---

**Built with ❤️ for aspiring drivers everywhere.**
