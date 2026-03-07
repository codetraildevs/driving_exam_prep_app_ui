import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Traffic Rules Learning App'**
  String get appTitle;

  /// Title on the first-run language selector screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get languageSelectTitle;

  /// Subtitle on language selector screen
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings'**
  String get languageSelectSubtitle;

  /// Confirm button on language selector
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageSelectConfirm;

  /// Greeting label on home page header
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get homeWelcomeBack;

  /// User name displayed in home header
  ///
  /// In en, this message translates to:
  /// **'{userName}'**
  String homeGreeting(String userName);

  /// Motivational sub-text on home page
  ///
  /// In en, this message translates to:
  /// **'Continue mastering traffic rules today.'**
  String get homeContinueMessage;

  /// CTA button text on home page
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get homeContinueLearning;

  /// Access card status
  ///
  /// In en, this message translates to:
  /// **'Access Active - {daysLeft} days left'**
  String homeAccessActive(int daysLeft);

  /// Payment tier label
  ///
  /// In en, this message translates to:
  /// **'Payment Tier: {tier}'**
  String homePaymentTier(String tier);

  /// Plural example: number of practice sessions completed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No practice sessions} =1{1 practice session} other{{count} practice sessions}}'**
  String homePracticeSessions(int count);

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Practices'**
  String get homePractices;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Practice questions'**
  String get homePracticesSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get homeCourses;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Learning modules'**
  String get homeCoursesSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get homeMockExams;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Test knowledge'**
  String get homeMockExamsSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgress;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Track performance'**
  String get homeProgressSubtitle;

  /// Service card title
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get homeShareApp;

  /// Service card subtitle
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get homeShareAppSubtitle;

  /// Settings page app bar title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// Dark mode toggle title
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// Dark mode toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get settingsDarkModeSubtitle;

  /// Notifications toggle title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Notifications toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive daily reminders'**
  String get settingsNotificationsSubtitle;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// About app title
  ///
  /// In en, this message translates to:
  /// **'About Traffic Rules App'**
  String get settingsAboutApp;

  /// App version with interpolation
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// Privacy policy link title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// Privacy policy subtitle
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get settingsPrivacyPolicySubtitle;

  /// Terms of service link title
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// Terms subtitle
  ///
  /// In en, this message translates to:
  /// **'Read our terms'**
  String get settingsTermsOfServiceSubtitle;

  /// Data section header
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// Reset progress button title
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingsResetProgress;

  /// Reset progress subtitle
  ///
  /// In en, this message translates to:
  /// **'Clear all your data'**
  String get settingsResetProgressSubtitle;

  /// Reset confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingsResetConfirmTitle;

  /// Reset confirm dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your progress? This action cannot be undone.'**
  String get settingsResetConfirmMessage;

  /// Reset success snackbar message
  ///
  /// In en, this message translates to:
  /// **'Progress reset successfully'**
  String get settingsResetSuccess;

  /// Language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Generic reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// Landing page hero title
  ///
  /// In en, this message translates to:
  /// **'Master Traffic Rules Easily'**
  String get landingHeroTitle;

  /// Landing page hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Prepare smarter. Practice real exam questions. Track your progress and pass your driving license exam with confidence.'**
  String get landingHeroSubtitle;

  /// Landing page CTA button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get landingGetStarted;

  /// Landing page login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get landingAlreadyHaveAccount;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Why Use Our App?'**
  String get landingWhyUseApp;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Learn Rules'**
  String get landingLearnRules;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Clear explanations of all traffic laws and road signs.'**
  String get landingLearnRulesDesc;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get landingPracticeExams;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Take mock exams similar to the real driving test.'**
  String get landingPracticeExamsDesc;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get landingTrackProgress;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Monitor your performance and improve weak areas.'**
  String get landingTrackProgressDesc;

  /// How it works section title
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get landingHowItWorks;

  /// How it works step 1
  ///
  /// In en, this message translates to:
  /// **'Create your free account'**
  String get landingStep1;

  /// How it works step 2
  ///
  /// In en, this message translates to:
  /// **'Start learning traffic rules'**
  String get landingStep2;

  /// How it works step 3
  ///
  /// In en, this message translates to:
  /// **'Take mock exams'**
  String get landingStep3;

  /// How it works step 4
  ///
  /// In en, this message translates to:
  /// **'Pass your real test confidently'**
  String get landingStep4;

  /// Landing CTA section title
  ///
  /// In en, this message translates to:
  /// **'Ready to Pass Your Driving Exam?'**
  String get landingReadyTitle;

  /// Landing CTA button
  ///
  /// In en, this message translates to:
  /// **'Start Learning Now'**
  String get landingStartLearning;

  /// Services section header on home page
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeServices;

  /// App brand name on auth pages
  ///
  /// In en, this message translates to:
  /// **'RWANDA TRAFFIC RULES'**
  String get authAppName;

  /// Subtitle on auth pages
  ///
  /// In en, this message translates to:
  /// **'Official Driving License Learning Platform'**
  String get authSubtitle;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Login to Your Account'**
  String get loginTitle;

  /// Login page subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your registered phone number to continue.'**
  String get loginSubtitle;

  /// Help section title on auth pages
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get authNeedHelp;

  /// Login help text
  ///
  /// In en, this message translates to:
  /// **'For account issues or inquiries, contact:'**
  String get loginHelpText;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// Phone number placeholder
  ///
  /// In en, this message translates to:
  /// **'0788 000 000'**
  String get authPhoneHint;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// Sign up link text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// Brand tagline on auth pages
  ///
  /// In en, this message translates to:
  /// **'Secure • Fast • Official Road App'**
  String get authSecureTag;

  /// Phone validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get loginPhoneRequired;

  /// Registration page title
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registerTitle;

  /// Registration page subtitle
  ///
  /// In en, this message translates to:
  /// **'Register using your full name and phone number to begin learning.'**
  String get registerSubtitle;

  /// Registration help text
  ///
  /// In en, this message translates to:
  /// **'For registration issues or inquiries, contact:'**
  String get registerHelpText;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// Full name placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// Terms agreement text
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get registerTerms;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerSignUp;

  /// Have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// Log in link text
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get registerLogIn;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get registerFillAllFields;

  /// Terms validation error
  ///
  /// In en, this message translates to:
  /// **'Please agree to terms and conditions'**
  String get registerAgreeTerms;

  /// Forgot password page title
  ///
  /// In en, this message translates to:
  /// **'Password reset is not available'**
  String get forgotPasswordTitle;

  /// Forgot password page description
  ///
  /// In en, this message translates to:
  /// **'This backend uses phone number + device binding (no password reset flow).'**
  String get forgotPasswordDescription;

  /// Back to login button
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// Bottom nav home label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav practice label
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// Bottom nav progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// Bottom nav profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Practice page title
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get practiceTitle;

  /// Practice category
  ///
  /// In en, this message translates to:
  /// **'Speed Limits'**
  String get practiceCategorySpeedLimits;

  /// Practice category
  ///
  /// In en, this message translates to:
  /// **'Road Signs'**
  String get practiceCategoryRoadSigns;

  /// Practice category
  ///
  /// In en, this message translates to:
  /// **'Lane Control'**
  String get practiceCategoryLaneControl;

  /// Practice category
  ///
  /// In en, this message translates to:
  /// **'Parking Rules'**
  String get practiceCategoryParkingRules;

  /// Start quiz prompt
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get practiceStart;

  /// Quiz completion title
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Quiz score display
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String quizScore(int score);

  /// Quiz result text
  ///
  /// In en, this message translates to:
  /// **'You got {correct} out of {total} correct'**
  String quizResult(int correct, int total);

  /// Back button in quiz results
  ///
  /// In en, this message translates to:
  /// **'Back to Practice'**
  String get quizBackToPractice;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String quizQuestion(int current, int total);

  /// Finish quiz button
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get quizFinish;

  /// Next question button
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get quizNextQuestion;

  /// Mock exam title
  ///
  /// In en, this message translates to:
  /// **'Practice Exam'**
  String get examMockExam;

  /// Exam instructions title
  ///
  /// In en, this message translates to:
  /// **'Exam Instructions'**
  String get examInstructions;

  /// Time limit instruction title
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get examTimeLimit;

  /// Time limit description
  ///
  /// In en, this message translates to:
  /// **'30 minutes total for 20 questions'**
  String get examTimeLimitDesc;

  /// Question count instruction title
  ///
  /// In en, this message translates to:
  /// **'20 Questions'**
  String get examQuestionCount;

  /// Question count description
  ///
  /// In en, this message translates to:
  /// **'Multiple choice format with 4 options each'**
  String get examQuestionCountDesc;

  /// Passing score instruction title
  ///
  /// In en, this message translates to:
  /// **'Passing Score'**
  String get examPassingScore;

  /// Passing score description
  ///
  /// In en, this message translates to:
  /// **'You need 70% or higher to pass'**
  String get examPassingScoreDesc;

  /// No going back instruction title
  ///
  /// In en, this message translates to:
  /// **'No Going Back'**
  String get examNoGoingBack;

  /// No going back description
  ///
  /// In en, this message translates to:
  /// **'You cannot revisit previous questions'**
  String get examNoGoingBackDesc;

  /// Exam warning message
  ///
  /// In en, this message translates to:
  /// **'Make sure you have stable internet and won\'t be interrupted'**
  String get examWarning;

  /// Start exam button
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get examStartExam;

  /// Submit exam button
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get examSubmit;

  /// Exam passed title
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get examCongratulations;

  /// Exam failed title
  ///
  /// In en, this message translates to:
  /// **'Good Effort'**
  String get examGoodEffort;

  /// Exam passed message
  ///
  /// In en, this message translates to:
  /// **'You passed the exam with flying colors!'**
  String get examPassedMessage;

  /// Exam failed message
  ///
  /// In en, this message translates to:
  /// **'Keep practicing to improve your score'**
  String get examFailedMessage;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get examYourScore;

  /// Correct answers label
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get examCorrect;

  /// Accuracy label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get examAccuracy;

  /// Encouragement for failing
  ///
  /// In en, this message translates to:
  /// **'You need 70% to pass. Practice more to improve!'**
  String get examNeedMorePractice;

  /// Badge earned message
  ///
  /// In en, this message translates to:
  /// **'You earned a badge for passing the exam!'**
  String get examBadgeEarned;

  /// Retake test button
  ///
  /// In en, this message translates to:
  /// **'Retake Test'**
  String get examRetakeTest;

  /// Back home button
  ///
  /// In en, this message translates to:
  /// **'Back Home'**
  String get examBackHome;

  /// Progress page title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressTitle;

  /// Performance section title
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get progressPerformanceSummary;

  /// Total attempts stat
  ///
  /// In en, this message translates to:
  /// **'Total Attempts'**
  String get progressTotalAttempts;

  /// Best score stat
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get progressBestScore;

  /// Average score stat
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get progressAverageScore;

  /// Signs learned stat
  ///
  /// In en, this message translates to:
  /// **'Signs Learned'**
  String get progressSignsLearned;

  /// Recent exams section title
  ///
  /// In en, this message translates to:
  /// **'Recent Exams'**
  String get progressRecentExams;

  /// Overall progress card title
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get progressOverall;

  /// Complete metric label
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get progressComplete;

  /// Average score metric label
  ///
  /// In en, this message translates to:
  /// **'Avg Score'**
  String get progressAvgScore;

  /// Signs metric label
  ///
  /// In en, this message translates to:
  /// **'Signs'**
  String get progressSigns;

  /// Passed status label
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get progressPassed;

  /// Excellent status label
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get progressExcellent;

  /// Mock exam name
  ///
  /// In en, this message translates to:
  /// **'Mock Exam {number}'**
  String progressMockExam(int number);

  /// Practice quiz name
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get progressPracticeQuiz;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// User location
  ///
  /// In en, this message translates to:
  /// **'Kigali, Rwanda'**
  String get profileLocation;

  /// Learning progress card title
  ///
  /// In en, this message translates to:
  /// **'Overall Learning Progress'**
  String get profileOverallProgress;

  /// Module completion text
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Modules Completed'**
  String profileModulesCompleted(int completed, int total);

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// Settings menu subtitle
  ///
  /// In en, this message translates to:
  /// **'Notifications, language, privacy'**
  String get profileSettingsSubtitle;

  /// Delete account option
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// Sign out option
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteConfirmTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get profileDeleteConfirmMessage;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// Certificates page title
  ///
  /// In en, this message translates to:
  /// **'My Certificates'**
  String get certificatesTitle;

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Your Achievements'**
  String get certificatesAchievements;

  /// Earned status
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get certificatesEarned;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get certificatesPending;

  /// In progress date placeholder
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get certificatesInProgress;

  /// Certificate name
  ///
  /// In en, this message translates to:
  /// **'Road Signs Mastery'**
  String get certificateRoadSignsMastery;

  /// Certificate name
  ///
  /// In en, this message translates to:
  /// **'Traffic Rules Final Test'**
  String get certificateTrafficRulesTest;

  /// Certificate name
  ///
  /// In en, this message translates to:
  /// **'Defensive Driving'**
  String get certificateDefensiveDriving;

  /// Signs page title
  ///
  /// In en, this message translates to:
  /// **'Traffic Signs'**
  String get signsTitle;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search traffic signs...'**
  String get signsSearchHint;

  /// Empty state text
  ///
  /// In en, this message translates to:
  /// **'No traffic signs found'**
  String get signsNotFound;

  /// Learned badge text
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get signsLearned;

  /// All category filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get signsAll;

  /// Sign detail page title
  ///
  /// In en, this message translates to:
  /// **'Traffic Sign'**
  String get signDetailTitle;

  /// Sign not found message
  ///
  /// In en, this message translates to:
  /// **'Sign not found'**
  String get signDetailNotFound;

  /// Description section header
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get signDetailDescription;

  /// Scenario section header
  ///
  /// In en, this message translates to:
  /// **'Real-Life Scenario'**
  String get signDetailScenario;

  /// Learned status message
  ///
  /// In en, this message translates to:
  /// **'You\'ve learned this sign!'**
  String get signDetailLearned;

  /// Mark as learned button
  ///
  /// In en, this message translates to:
  /// **'Mark as Learned'**
  String get signDetailMarkAsLearned;

  /// Success snackbar message
  ///
  /// In en, this message translates to:
  /// **'Traffic sign marked as learned!'**
  String get signDetailMarkedSuccess;

  /// Subscription page title
  ///
  /// In en, this message translates to:
  /// **'Practice Exam Access'**
  String get subscriptionTitle;

  /// Subscription page subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock All Practice Exams'**
  String get subscriptionSubtitle;

  /// Current plan section label
  ///
  /// In en, this message translates to:
  /// **'Your Current Plan'**
  String get subscriptionCurrentPlan;

  /// No plan label
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get subscriptionNoPlan;

  /// 1 month plan label
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get subscriptionMonth1;

  /// 3 months plan label
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get subscriptionMonth3;

  /// 6 months plan label
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get subscriptionMonth6;

  /// Price label with amount
  ///
  /// In en, this message translates to:
  /// **'{amount} RWF'**
  String subscriptionPrice(int amount);

  /// Request access button
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get subscriptionRequestAccess;

  /// Request sent success message
  ///
  /// In en, this message translates to:
  /// **'Your request has been submitted. You will be activated once payment is confirmed.'**
  String get subscriptionRequestSent;

  /// Payment instructions section title
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get subscriptionPaymentInstructions;

  /// MoMo pay number
  ///
  /// In en, this message translates to:
  /// **'MoMo Pay: 323294'**
  String get subscriptionPaymentMomo;

  /// Mobile money number
  ///
  /// In en, this message translates to:
  /// **'Mobile Money: 0788657595'**
  String get subscriptionPaymentMobile;

  /// Help call number
  ///
  /// In en, this message translates to:
  /// **'Call: 0788657595'**
  String get subscriptionHelpCall;

  /// Help WhatsApp number
  ///
  /// In en, this message translates to:
  /// **'WhatsApp: 0788657595'**
  String get subscriptionHelpWhatsapp;

  /// Choose plan label
  ///
  /// In en, this message translates to:
  /// **'Choose a Plan'**
  String get subscriptionChoosePlan;

  /// Currency label
  ///
  /// In en, this message translates to:
  /// **'Currency: RWF'**
  String get subscriptionCurrency;

  /// Access active label
  ///
  /// In en, this message translates to:
  /// **'Access Active'**
  String get subscriptionAccessActive;

  /// Expiry date label
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String subscriptionExpires(String date);

  /// Days label
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String subscriptionDays(int days);

  /// Need help label
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get subscriptionNeedHelp;

  /// Get access subtitle
  ///
  /// In en, this message translates to:
  /// **'Get access to all {count}+ premium practice exams'**
  String subscriptionGetAccess(int count);

  /// Admin dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// Admin users page title
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// Admin access page title
  ///
  /// In en, this message translates to:
  /// **'Access Management'**
  String get adminAccess;

  /// Admin progress page title
  ///
  /// In en, this message translates to:
  /// **'User Progress'**
  String get adminProgress;

  /// Total users stat label
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// Active subscriptions stat label
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get adminActiveSubscriptions;

  /// Users by language stat label
  ///
  /// In en, this message translates to:
  /// **'Users by Language'**
  String get adminUsersByLanguage;

  /// Recent registrations stat label
  ///
  /// In en, this message translates to:
  /// **'Recent Registrations'**
  String get adminRecentRegistrations;

  /// Grant access button
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get adminGrantAccess;

  /// Call user button
  ///
  /// In en, this message translates to:
  /// **'Call User'**
  String get adminCallUser;

  /// Call notes label
  ///
  /// In en, this message translates to:
  /// **'Call Notes'**
  String get adminCallNotes;

  /// Last called label
  ///
  /// In en, this message translates to:
  /// **'Last Called'**
  String get adminLastCalled;

  /// No access badge
  ///
  /// In en, this message translates to:
  /// **'No Access'**
  String get adminNoAccess;

  /// Has access badge
  ///
  /// In en, this message translates to:
  /// **'Has Access'**
  String get adminHasAccess;

  /// Access expired badge
  ///
  /// In en, this message translates to:
  /// **'Access Expired'**
  String get adminAccessExpired;

  /// Access expiry date
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String adminAccessExpires(String date);

  /// Search users hint
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get adminSearchUsers;

  /// Filter all chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// Filter has access chip
  ///
  /// In en, this message translates to:
  /// **'Has Access'**
  String get adminFilterHasAccess;

  /// Filter no access chip
  ///
  /// In en, this message translates to:
  /// **'No Access'**
  String get adminFilterNoAccess;

  /// Manage users quick action
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get adminManageUsers;

  /// Manage access quick action
  ///
  /// In en, this message translates to:
  /// **'Manage Access'**
  String get adminManageAccess;

  /// View progress quick action
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get adminViewProgress;

  /// Registration date label
  ///
  /// In en, this message translates to:
  /// **'Registered: {date}'**
  String adminRegistrationDate(String date);

  /// Call notes hint text
  ///
  /// In en, this message translates to:
  /// **'Enter call notes...'**
  String get adminEnterCallNotes;

  /// Submit call notes button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get adminSubmitCall;

  /// Call logged success message
  ///
  /// In en, this message translates to:
  /// **'Call logged successfully'**
  String get adminCallLogged;

  /// Access granted success message
  ///
  /// In en, this message translates to:
  /// **'Access granted successfully'**
  String get adminAccessGranted;

  /// Select tier label
  ///
  /// In en, this message translates to:
  /// **'Select Access Tier'**
  String get adminSelectTier;

  /// Custom days label
  ///
  /// In en, this message translates to:
  /// **'Custom Duration (days)'**
  String get adminCustomDays;

  /// Payment amount label
  ///
  /// In en, this message translates to:
  /// **'Amount (RWF)'**
  String get adminPaymentAmount;

  /// Days input hint
  ///
  /// In en, this message translates to:
  /// **'Enter number of days'**
  String get adminEnterDays;

  /// Amount input hint
  ///
  /// In en, this message translates to:
  /// **'Enter amount in RWF'**
  String get adminEnterAmount;

  /// Custom days toggle label
  ///
  /// In en, this message translates to:
  /// **'Or set custom days'**
  String get adminOrCustom;

  /// Pending requests section title
  ///
  /// In en, this message translates to:
  /// **'Pending Payment Requests'**
  String get adminPendingRequests;

  /// All users section title
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get adminAllUsersList;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get adminInvalidAmount;

  /// Invalid days error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of days greater than 0'**
  String get adminInvalidDays;

  /// Access revoked message
  ///
  /// In en, this message translates to:
  /// **'Access revoked'**
  String get adminAccessRevoked;

  /// No users found message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminNoUsers;

  /// Exam list page title
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get examListTitle;

  /// Free exam badge
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get examFree;

  /// Paid exam badge
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get examPaid;

  /// Locked exam label
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get examLocked;

  /// Question count label
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String examQuestions(int count);

  /// Quiz progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get quizProgress;

  /// Answered counter
  ///
  /// In en, this message translates to:
  /// **'Answered: {answered}/{total}'**
  String quizAnswered(int answered, int total);

  /// Submit practice button
  ///
  /// In en, this message translates to:
  /// **'Submit Practice'**
  String get quizSubmitPractice;

  /// Previous question button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get quizPrevious;

  /// Next question button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// Time remaining label
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String quizTimeRemaining(String time);

  /// Quiz results title
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResults;

  /// Quiz passed label
  ///
  /// In en, this message translates to:
  /// **'Passed!'**
  String get quizPassed;

  /// Quiz failed label
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing'**
  String get quizFailed;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(int current, int total);

  /// Submit confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Submit Quiz?'**
  String get quizSubmitConfirmTitle;

  /// Submit confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'You have answered {answered} out of {total} questions. Are you sure you want to submit?'**
  String quizSubmitConfirmMessage(int answered, int total);

  /// Time up message
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! Quiz submitted automatically.'**
  String get quizTimeUp;

  /// Review answers button
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get quizReviewAnswers;

  /// Retake quiz button
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get quizRetake;

  /// Profile role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// Profile language label
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get profileLanguage;

  /// Registration date
  ///
  /// In en, this message translates to:
  /// **'Registered: {date}'**
  String profileRegistered(String date);

  /// Access status label
  ///
  /// In en, this message translates to:
  /// **'Access Status'**
  String get profileAccessStatus;

  /// Exam history label
  ///
  /// In en, this message translates to:
  /// **'Exam History'**
  String get profileExamHistory;

  /// Call history label
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get profileCallHistory;

  /// Payment instructions title
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get paymentInstructionsTitle;

  /// MoMo pay number
  ///
  /// In en, this message translates to:
  /// **'MoMo Pay: 323294'**
  String get paymentMomoPayNumber;

  /// MoMo Pay dial instruction
  ///
  /// In en, this message translates to:
  /// **'To pay with MoMo Pay, dial: *182*1*1*323294*amount#'**
  String get paymentMomoPayDial;

  /// Mobile money number
  ///
  /// In en, this message translates to:
  /// **'Mobile Money: 0788657595'**
  String get paymentMobileMoneyNumber;

  /// Mobile Money dial instruction
  ///
  /// In en, this message translates to:
  /// **'To pay with Mobile Money, dial: *182*8*1*0788657595*amount#'**
  String get paymentMobileMoneyDial;

  /// Payment help text
  ///
  /// In en, this message translates to:
  /// **'Need help? Call or WhatsApp: 0788657595'**
  String get paymentHelpText;

  /// Payment help contact line
  ///
  /// In en, this message translates to:
  /// **'You can copy or call: 0788657595 or WhatsApp: 0788657595 for help.'**
  String get paymentHelpContact;

  /// Payment error message
  ///
  /// In en, this message translates to:
  /// **'Payment request failed. Please pay manually using the instructions below.'**
  String get paymentError;

  /// Copy phone number button
  ///
  /// In en, this message translates to:
  /// **'Copy Number'**
  String get paymentCopyNumber;

  /// Call phone number button
  ///
  /// In en, this message translates to:
  /// **'Call 0788657595'**
  String get paymentCallNumber;

  /// WhatsApp button label
  ///
  /// In en, this message translates to:
  /// **'WhatsApp: Send Message'**
  String get paymentWhatsApp;

  /// WhatsApp message text for payment request
  ///
  /// In en, this message translates to:
  /// **'Request access for driving exam app'**
  String get paymentWhatsAppMessage;

  /// Duplicate payment request error
  ///
  /// In en, this message translates to:
  /// **'A payment request for this plan is already pending. Please wait for activation or contact support.'**
  String get paymentRequestExists;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonError;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @adminTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get adminTierLabel;

  /// No description provided for @adminExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get adminExpiresLabel;

  /// No description provided for @adminRenewAccess.
  ///
  /// In en, this message translates to:
  /// **'Renew / Extend Access'**
  String get adminRenewAccess;

  /// No description provided for @adminManagePlatform.
  ///
  /// In en, this message translates to:
  /// **'Manage Platform'**
  String get adminManagePlatform;

  /// No description provided for @adminManageExams.
  ///
  /// In en, this message translates to:
  /// **'Manage Exams'**
  String get adminManageExams;

  /// No description provided for @adminManageExamsDesc.
  ///
  /// In en, this message translates to:
  /// **'View and manage all practice exams'**
  String get adminManageExamsDesc;

  /// No description provided for @adminManageUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'View, search, and manage all users'**
  String get adminManageUsersDesc;

  /// No description provided for @adminAccessCodesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage access codes and payments'**
  String get adminAccessCodesDesc;

  /// No description provided for @adminQuickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get adminQuickStats;

  /// No description provided for @adminActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Actions'**
  String get adminActionsTitle;

  /// No description provided for @adminTotalPractices.
  ///
  /// In en, this message translates to:
  /// **'Total Practices'**
  String get adminTotalPractices;

  /// No description provided for @adminManagePlatformDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your traffic rules learning platform'**
  String get adminManagePlatformDesc;

  /// No description provided for @adminNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get adminNotifications;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how the app looks'**
  String get settingsAppearanceDesc;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Wrong answers label in exam result
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get examWrong;

  /// Time spent label in exam result
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get examTimeSpent;

  /// Logout confirmation title
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get profileLogoutConfirmTitle;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get profileLogoutConfirmMessage;

  /// Instructions shown before deleting account
  ///
  /// In en, this message translates to:
  /// **'Before deleting your account:\n• All your exam results will be permanently erased\n• Your access subscription will be removed\n• This action cannot be undone\n• You will need to re-register to use the app again'**
  String get profileDeleteInstructions;

  /// Total exams taken label
  ///
  /// In en, this message translates to:
  /// **'Exams Taken'**
  String get progressExamsTaken;

  /// Number of passed exams label
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get progressPassedCount;

  /// Number of failed exams label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get progressFailedCount;

  /// Pass rate label
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get progressPassRate;

  /// Empty state for progress page
  ///
  /// In en, this message translates to:
  /// **'No exams taken yet. Start practicing!'**
  String get progressNoExams;

  /// Certificate ready title
  ///
  /// In en, this message translates to:
  /// **'Ready for Official Exam!'**
  String get certificateReadyTitle;

  /// Certificate subtitle with count
  ///
  /// In en, this message translates to:
  /// **'You have passed {count} exams. You are ready for the official driving license test.'**
  String certificateReadySubtitle(int count);

  /// Irembo link button label
  ///
  /// In en, this message translates to:
  /// **'Register for Official Exam on irembo.gov.rw'**
  String get certificateIremboLink;

  /// Irembo link description
  ///
  /// In en, this message translates to:
  /// **'Click below to register for the official provisional driving license computer-based test'**
  String get certificateIremboDesc;

  /// How many more exams needed
  ///
  /// In en, this message translates to:
  /// **'Pass {needed} more exams to earn your certificate'**
  String certificateExamsNeeded(int needed);

  /// Certificate progress label
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} required exams passed'**
  String certificateProgressLabel(int passed, int total);

  /// Sort ascending label
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get adminSortAsc;

  /// Sort descending label
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get adminSortDesc;

  /// Filter today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get adminFilterToday;

  /// Date range filter label
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get adminDateRange;

  /// Filter by role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminFilterRole;

  /// Block user action
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get adminBlockUser;

  /// Unblock user action
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get adminUnblockUser;

  /// Delete user action
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminDeleteUserAction;

  /// Block user confirmation
  ///
  /// In en, this message translates to:
  /// **'Block {name}? They will lose access and cannot log in.'**
  String adminBlockUserConfirm(String name);

  /// Delete user confirmation
  ///
  /// In en, this message translates to:
  /// **'Permanently delete {name}? All their data will be erased. This cannot be undone.'**
  String adminDeleteUserConfirm(String name);

  /// User blocked success message
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get adminUserBlocked;

  /// User unblocked success message
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get adminUserUnblocked;

  /// User deleted success message
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get adminUserDeleted;

  /// Must block first error message
  ///
  /// In en, this message translates to:
  /// **'You must block the user before deleting them.'**
  String get adminMustBlockFirst;

  /// Block access action
  ///
  /// In en, this message translates to:
  /// **'Block Access'**
  String get adminBlockAccess;

  /// Delete access action
  ///
  /// In en, this message translates to:
  /// **'Delete Access'**
  String get adminDeleteAccess;

  /// Block access confirmation
  ///
  /// In en, this message translates to:
  /// **'Block this access code? The user will lose access immediately.'**
  String get adminBlockAccessConfirm;

  /// Delete access confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this access code permanently?'**
  String get adminDeleteAccessConfirm;

  /// Access blocked success message
  ///
  /// In en, this message translates to:
  /// **'Access code blocked'**
  String get adminAccessBlocked;

  /// Access deleted success message
  ///
  /// In en, this message translates to:
  /// **'Access code deleted'**
  String get adminAccessDeleted;

  /// Pagination label
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String adminPage(int page, int total);

  /// Learning language label
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get adminLearningLanguage;

  /// Blocked status label
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get adminIsBlocked;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminIsActive;

  /// Shown in snackbar after copying text to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get generalCopied;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get adminRetry;

  /// Full subtitle on language selector page
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings — get localized traffic alerts and routing.'**
  String get languageSelectDescription;

  /// Button to auto-detect device language
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSelectDeviceLanguage;

  /// Tooltip for help icon on language selector
  ///
  /// In en, this message translates to:
  /// **'Language help'**
  String get languageSelectHelpTooltip;

  /// Skip button on language selector
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get languageSelectMaybeLater;

  /// Help modal title on language selector
  ///
  /// In en, this message translates to:
  /// **'Why choose a language?'**
  String get languageSelectHelpTitle;

  /// Help modal content on language selector
  ///
  /// In en, this message translates to:
  /// **'Selecting a language ensures that alerts, maps, and voice prompts are shown in your preferred language. You can change this later in Settings.'**
  String get languageSelectHelpContent;

  /// Acknowledge button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// Dialog title for language picker
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get languageSelectDialogTitle;

  /// Error when exam cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Exam not found'**
  String get examNotFound;

  /// Error message with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String errorWithDetail(String detail);

  /// Unexpected error message with detail
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {detail}'**
  String errorUnexpected(String detail);

  /// Price formatted in RWF
  ///
  /// In en, this message translates to:
  /// **'{amount} RWF'**
  String priceRwf(String amount);

  /// HTTP error status
  ///
  /// In en, this message translates to:
  /// **'HTTP {code}'**
  String errorHttpStatus(int code);

  /// Sample exam question 1
  ///
  /// In en, this message translates to:
  /// **'What is the speed limit on highways?'**
  String get examSampleQ1;

  /// No description provided for @examSampleQ1A1.
  ///
  /// In en, this message translates to:
  /// **'90 km/h'**
  String get examSampleQ1A1;

  /// No description provided for @examSampleQ1A2.
  ///
  /// In en, this message translates to:
  /// **'100 km/h'**
  String get examSampleQ1A2;

  /// No description provided for @examSampleQ1A3.
  ///
  /// In en, this message translates to:
  /// **'110 km/h'**
  String get examSampleQ1A3;

  /// No description provided for @examSampleQ1A4.
  ///
  /// In en, this message translates to:
  /// **'120 km/h'**
  String get examSampleQ1A4;

  /// Sample exam question 2
  ///
  /// In en, this message translates to:
  /// **'What does a yellow traffic light mean?'**
  String get examSampleQ2;

  /// No description provided for @examSampleQ2A1.
  ///
  /// In en, this message translates to:
  /// **'Stop immediately'**
  String get examSampleQ2A1;

  /// No description provided for @examSampleQ2A2.
  ///
  /// In en, this message translates to:
  /// **'Go ahead'**
  String get examSampleQ2A2;

  /// No description provided for @examSampleQ2A3.
  ///
  /// In en, this message translates to:
  /// **'Be prepared to stop'**
  String get examSampleQ2A3;

  /// No description provided for @examSampleQ2A4.
  ///
  /// In en, this message translates to:
  /// **'Turn around'**
  String get examSampleQ2A4;

  /// Sample exam question 3
  ///
  /// In en, this message translates to:
  /// **'How far from a fire hydrant can you park?'**
  String get examSampleQ3;

  /// No description provided for @examSampleQ3A1.
  ///
  /// In en, this message translates to:
  /// **'1 meter'**
  String get examSampleQ3A1;

  /// No description provided for @examSampleQ3A2.
  ///
  /// In en, this message translates to:
  /// **'3 meters'**
  String get examSampleQ3A2;

  /// No description provided for @examSampleQ3A3.
  ///
  /// In en, this message translates to:
  /// **'5 meters'**
  String get examSampleQ3A3;

  /// No description provided for @examSampleQ3A4.
  ///
  /// In en, this message translates to:
  /// **'10 meters'**
  String get examSampleQ3A4;

  /// No description provided for @examShareResult.
  String get examShareResult;

  /// No description provided for @examCopiedToClipboard.
  String get examCopiedToClipboard;

  /// No description provided for @examGradeLabel.
  String get examGradeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
