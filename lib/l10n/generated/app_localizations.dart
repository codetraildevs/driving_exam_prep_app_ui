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
  String get subscriptionTitle;

  /// Subscription page subtitle
  String get subscriptionSubtitle;

  /// Current plan section label
  String get subscriptionCurrentPlan;

  /// No plan label
  String get subscriptionNoPlan;

  /// 1 month plan label
  String get subscriptionMonth1;

  /// 3 months plan label
  String get subscriptionMonth3;

  /// 6 months plan label
  String get subscriptionMonth6;

  /// Price label with amount
  String subscriptionPrice(int amount);

  /// Request access button
  String get subscriptionRequestAccess;

  /// Request sent success message
  String get subscriptionRequestSent;

  /// Payment instructions section title
  String get subscriptionPaymentInstructions;

  /// MoMo pay number
  String get subscriptionPaymentMomo;

  /// Mobile money number
  String get subscriptionPaymentMobile;

  /// Help call number
  String get subscriptionHelpCall;

  /// Help WhatsApp number
  String get subscriptionHelpWhatsapp;

  /// Choose plan label
  String get subscriptionChoosePlan;

  /// Currency label
  String get subscriptionCurrency;

  /// Access active label
  String get subscriptionAccessActive;

  /// Expiry date label
  String subscriptionExpires(String date);

  /// Days label
  String subscriptionDays(int days);

  /// Need help label
  String get subscriptionNeedHelp;

  /// Get access subtitle
  String subscriptionGetAccess(int count);

  /// Admin dashboard page title
  String get adminDashboard;

  /// Admin users page title
  String get adminUsers;

  /// Admin access page title
  String get adminAccess;

  /// Admin progress page title
  String get adminProgress;

  /// Total users stat label
  String get adminTotalUsers;

  /// Active subscriptions stat label
  String get adminActiveSubscriptions;

  /// Users by language stat label
  String get adminUsersByLanguage;

  /// Recent registrations stat label
  String get adminRecentRegistrations;

  /// Grant access button
  String get adminGrantAccess;

  /// Call user button
  String get adminCallUser;

  /// Call notes label
  String get adminCallNotes;

  /// Last called label
  String get adminLastCalled;

  /// No access badge
  String get adminNoAccess;

  /// Has access badge
  String get adminHasAccess;

  /// Access expired badge
  String get adminAccessExpired;

  /// Access expiry date
  String adminAccessExpires(String date);

  /// Search users hint
  String get adminSearchUsers;

  /// Filter all chip
  String get adminFilterAll;

  /// Filter has access chip
  String get adminFilterHasAccess;

  /// Filter no access chip
  String get adminFilterNoAccess;

  /// Manage users quick action
  String get adminManageUsers;

  /// Manage access quick action
  String get adminManageAccess;

  /// View progress quick action
  String get adminViewProgress;

  /// Registration date label
  String adminRegistrationDate(String date);

  /// Call notes hint text
  String get adminEnterCallNotes;

  /// Submit call notes button
  String get adminSubmitCall;

  /// Call logged success message
  String get adminCallLogged;

  /// Access granted success message
  String get adminAccessGranted;

  /// Select tier label
  String get adminSelectTier;

  /// Custom days label
  String get adminCustomDays;

  /// Payment amount label
  String get adminPaymentAmount;

  /// Days input hint
  String get adminEnterDays;

  /// Amount input hint
  String get adminEnterAmount;

  /// Custom days toggle label
  String get adminOrCustom;

  /// Pending requests section title
  String get adminPendingRequests;

  /// All users section title
  String get adminAllUsersList;

  /// Invalid amount error
  String get adminInvalidAmount;

  /// Invalid days error
  String get adminInvalidDays;

  /// Access revoked message
  String get adminAccessRevoked;

  /// No users found message
  String get adminNoUsers;

  /// Exam list page title
  String get examListTitle;

  /// Free exam badge
  String get examFree;

  /// Paid exam badge
  String get examPaid;

  /// Locked exam label
  String get examLocked;

  /// Question count label
  String examQuestions(int count);

  /// Quiz progress label
  String get quizProgress;

  /// Answered counter
  String quizAnswered(int answered, int total);

  /// Submit practice button
  String get quizSubmitPractice;

  /// Previous question button
  String get quizPrevious;

  /// Next question button
  String get quizNext;

  /// Time remaining label
  String quizTimeRemaining(String time);

  /// Quiz results title
  String get quizResults;

  /// Quiz passed label
  String get quizPassed;

  /// Quiz failed label
  String get quizFailed;

  /// Question counter
  String quizQuestionOf(int current, int total);

  /// Submit confirmation dialog title
  String get quizSubmitConfirmTitle;

  /// Submit confirmation dialog message
  String quizSubmitConfirmMessage(int answered, int total);

  /// Time up message
  String get quizTimeUp;

  /// Review answers button
  String get quizReviewAnswers;

  /// Retake quiz button
  String get quizRetake;

  /// Profile role label
  String get profileRole;

  /// Profile language label
  String get profileLanguage;

  /// Registration date
  String profileRegistered(String date);

  /// Access status label
  String get profileAccessStatus;

  /// Exam history label
  String get profileExamHistory;

  /// Call history label
  String get profileCallHistory;

  /// Payment instructions title
  String get paymentInstructionsTitle;

  /// MoMo pay number
  String get paymentMomoPayNumber;

  /// Mobile money number
  String get paymentMobileMoneyNumber;

  /// Payment help text
  String get paymentHelpText;

  /// Payment error message
  String get paymentError;

  /// Copy number button
  String get paymentCopyNumber;

  /// Call number button
  String get paymentCallNumber;

  /// WhatsApp button
  String get paymentWhatsApp;

  /// WhatsApp message text for payment request
  String get paymentWhatsAppMessage;

  /// Duplicate payment request error
  String get paymentRequestExists;

  /// Generic error message
  String get commonError;

  /// Retry button label
  String get commonRetry;

  /// Tier label
  String get adminTierLabel;

  /// Expires label
  String get adminExpiresLabel;

  /// Renew / extend access button
  String get adminRenewAccess;

  /// Manage Platform button
  String get adminManagePlatform;

  /// Manage Exams action
  String get adminManageExams;

  /// Manage Exams description
  String get adminManageExamsDesc;

  /// Manage Users description
  String get adminManageUsersDesc;

  /// Access Codes description
  String get adminAccessCodesDesc;

  /// Quick Stats section title
  String get adminQuickStats;

  /// Admin Actions section title
  String get adminActionsTitle;

  /// Total Practices stat
  String get adminTotalPractices;

  /// Admin platform description
  String get adminManagePlatformDesc;

  /// Notifications label
  String get adminNotifications;

  /// Appearance section title in Settings
  String get settingsAppearance;

  /// Appearance section subtitle
  String get settingsAppearanceDesc;

  /// System default theme chip label
  String get settingsThemeSystem;

  /// Light theme chip label
  String get settingsThemeLight;

  /// Dark theme chip label
  String get settingsThemeDark;

  // ── Exam result ─────────────────────────────────────────────────────────────
  String get examWrong;
  String get examTimeSpent;

  // ── Profile ──────────────────────────────────────────────────────────────────
  String get profileLogoutConfirmTitle;
  String get profileLogoutConfirmMessage;
  String get profileDeleteInstructions;

  // ── Progress page ────────────────────────────────────────────────────────────
  String get progressExamsTaken;
  String get progressPassedCount;
  String get progressFailedCount;
  String get progressPassRate;
  String get progressNoExams;

  // ── Certificates ─────────────────────────────────────────────────────────────
  String get certificateReadyTitle;
  String certificateReadySubtitle(int count);
  String get certificateIremboLink;
  String get certificateIremboDesc;
  String certificateExamsNeeded(int needed);
  String certificateProgressLabel(int passed, int total);

  // ── Admin extras ─────────────────────────────────────────────────────────────
  String get adminSortAsc;
  String get adminSortDesc;
  String get adminFilterToday;
  String get adminDateRange;
  String get adminFilterRole;
  String get adminBlockUser;
  String get adminUnblockUser;
  String get adminDeleteUserAction;
  String adminBlockUserConfirm(String name);
  String adminDeleteUserConfirm(String name);
  String get adminUserBlocked;
  String get adminUserUnblocked;
  String get adminUserDeleted;
  String get adminMustBlockFirst;
  String get adminBlockAccess;
  String get adminDeleteAccess;
  String get adminBlockAccessConfirm;
  String get adminDeleteAccessConfirm;
  String get adminAccessBlocked;
  String get adminAccessDeleted;
  String adminPage(int page, int total);
  String get adminLearningLanguage;
  String get adminIsBlocked;
  String get adminIsActive;
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
