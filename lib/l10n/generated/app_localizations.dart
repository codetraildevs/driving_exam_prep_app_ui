import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';
import 'app_localizations_sw.dart';

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
    Locale('rw'),
    Locale('sw'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule'**
  String get appTitle;

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get languageSelectTitle;

  /// No description provided for @languageSelectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings'**
  String get languageSelectSubtitle;

  /// No description provided for @languageSelectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageSelectConfirm;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get homeWelcomeBack;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'{userName}'**
  String homeGreeting(Object userName);

  /// No description provided for @homeContinueMessage.
  ///
  /// In en, this message translates to:
  /// **'Continue mastering traffic rules today.'**
  String get homeContinueMessage;

  /// No description provided for @homeContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get homeContinueLearning;

  /// No description provided for @homeAccessActive.
  ///
  /// In en, this message translates to:
  /// **'Access Active - {daysLeft} days left'**
  String homeAccessActive(Object daysLeft);

  /// No description provided for @homePaymentTier.
  ///
  /// In en, this message translates to:
  /// **'Payment Tier: {tier}'**
  String homePaymentTier(Object tier);

  /// Number of practice sessions completed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No practice sessions} =1{1 practice session} other{{count} practice sessions}}'**
  String homePracticeSessions(int count);

  /// No description provided for @homePractices.
  ///
  /// In en, this message translates to:
  /// **'Practices'**
  String get homePractices;

  /// No description provided for @homePracticesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice questions'**
  String get homePracticesSubtitle;

  /// No description provided for @homeCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get homeCourses;

  /// No description provided for @homeCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learning modules'**
  String get homeCoursesSubtitle;

  /// No description provided for @homeMockExams.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get homeMockExams;

  /// No description provided for @homeMockExamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test knowledge'**
  String get homeMockExamsSubtitle;

  /// No description provided for @homeProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get homeProgress;

  /// No description provided for @homeProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track performance'**
  String get homeProgressSubtitle;

  /// No description provided for @homeShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get homeShareApp;

  /// No description provided for @homeShareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get homeShareAppSubtitle;

  /// No description provided for @homeShareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Download Rwanda Traffic Rule to learn traffic rules and pass your exam!'**
  String get homeShareAppMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive daily reminders'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Rwanda Traffic Rule'**
  String get settingsAboutApp;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(Object version);

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get settingsPrivacyPolicySubtitle;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read our terms'**
  String get settingsTermsOfServiceSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all your data'**
  String get settingsResetProgressSubtitle;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your progress? This action cannot be undone.'**
  String get settingsResetConfirmMessage;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Progress reset successfully'**
  String get settingsResetSuccess;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get settingsSelectLanguage;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get commonMenu;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @landingHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn traffic rules easily'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice on your own questions and pass your exam.'**
  String get landingHeroSubtitle;

  /// No description provided for @landingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get landingGetStarted;

  /// No description provided for @landingAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get landingAlreadyHaveAccount;

  /// No description provided for @landingWhyUseApp.
  ///
  /// In en, this message translates to:
  /// **'Why use our app?'**
  String get landingWhyUseApp;

  /// No description provided for @landingLearnRules.
  ///
  /// In en, this message translates to:
  /// **'Learn rules'**
  String get landingLearnRules;

  /// No description provided for @landingLearnRulesDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear explanations of all traffic rules and signs.'**
  String get landingLearnRulesDesc;

  /// No description provided for @landingPracticeExams.
  ///
  /// In en, this message translates to:
  /// **'Practice exams'**
  String get landingPracticeExams;

  /// No description provided for @landingPracticeExamsDesc.
  ///
  /// In en, this message translates to:
  /// **'Take practice exams similar to the real exam.'**
  String get landingPracticeExamsDesc;

  /// No description provided for @landingTrackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get landingTrackProgress;

  /// No description provided for @landingTrackProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your performance and see where you want to go.'**
  String get landingTrackProgressDesc;

  /// No description provided for @landingHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get landingHowItWorks;

  /// No description provided for @landingStep1.
  ///
  /// In en, this message translates to:
  /// **'Open your free account'**
  String get landingStep1;

  /// No description provided for @landingStep2.
  ///
  /// In en, this message translates to:
  /// **'Start learning traffic rules'**
  String get landingStep2;

  /// No description provided for @landingStep3.
  ///
  /// In en, this message translates to:
  /// **'Take practice exams'**
  String get landingStep3;

  /// No description provided for @landingStep4.
  ///
  /// In en, this message translates to:
  /// **'Pass the real exam with confidence'**
  String get landingStep4;

  /// No description provided for @landingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to pass your health driving license exam?'**
  String get landingReadyTitle;

  /// No description provided for @landingStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning now'**
  String get landingStartLearning;

  /// No description provided for @homeServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get homeServices;

  /// No description provided for @authAppName.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule'**
  String get authAppName;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prepare for your provisional license driving theory exam'**
  String get authSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (used during registration) to continue.'**
  String get loginSubtitle;

  /// No description provided for @authNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get authNeedHelp;

  /// No description provided for @loginHelpText.
  ///
  /// In en, this message translates to:
  /// **'For account issues, contact:'**
  String get loginHelpText;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authPhoneNumber;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'07** *** ***'**
  String get authPhoneHint;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUp;

  /// No description provided for @authSecureTag.
  ///
  /// In en, this message translates to:
  /// **'Learn • Prepare • Pass'**
  String get authSecureTag;

  /// No description provided for @loginPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get loginPhoneRequired;

  /// No description provided for @loginInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (e.g., 07... or +250 7...)'**
  String get loginInvalidPhone;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up using your full name and phone number to start learning.'**
  String get registerSubtitle;

  /// No description provided for @registerHelpText.
  ///
  /// In en, this message translates to:
  /// **'For sign-up issues or other questions, contact:'**
  String get registerHelpText;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authFullNameHint;

  /// No description provided for @registerTerms.
  ///
  /// In en, this message translates to:
  /// **'Accept the usage and privacy policies.'**
  String get registerTerms;

  /// No description provided for @registerSignUp.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get registerSignUp;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get registerHaveAccount;

  /// No description provided for @registerLogIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerLogIn;

  /// No description provided for @registerFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get registerFillAllFields;

  /// No description provided for @registerAgreeTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept required terms'**
  String get registerAgreeTerms;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password not possible'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'The system uses phone number and device link (no password reset).'**
  String get forgotPasswordDescription;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get practiceTitle;

  /// No description provided for @practiceCategorySpeedLimits.
  ///
  /// In en, this message translates to:
  /// **'Speed limits'**
  String get practiceCategorySpeedLimits;

  /// No description provided for @practiceCategoryRoadSigns.
  ///
  /// In en, this message translates to:
  /// **'Traffic signs'**
  String get practiceCategoryRoadSigns;

  /// No description provided for @practiceCategoryLaneControl.
  ///
  /// In en, this message translates to:
  /// **'Lane guidance'**
  String get practiceCategoryLaneControl;

  /// No description provided for @practiceCategoryParkingRules.
  ///
  /// In en, this message translates to:
  /// **'Parking rules'**
  String get practiceCategoryParkingRules;

  /// No description provided for @practiceStart.
  ///
  /// In en, this message translates to:
  /// **'Start →'**
  String get practiceStart;

  /// No description provided for @quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Exam complete!'**
  String get quizComplete;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String quizScore(Object score);

  /// No description provided for @quizResult.
  ///
  /// In en, this message translates to:
  /// **'You answered {correct} out of {total} correctly'**
  String quizResult(Object correct, Object total);

  /// No description provided for @quizBackToPractice.
  ///
  /// In en, this message translates to:
  /// **'Try another exam'**
  String get quizBackToPractice;

  /// No description provided for @quizNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get quizNextQuestion;

  /// No description provided for @examMockExam.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get examMockExam;

  /// No description provided for @examInstructions.
  ///
  /// In en, this message translates to:
  /// **'Exam instructions'**
  String get examInstructions;

  /// No description provided for @examTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get examTimeLimit;

  /// No description provided for @examTimeLimitDesc.
  ///
  /// In en, this message translates to:
  /// **'30 minutes total with 20 questions'**
  String get examTimeLimitDesc;

  /// No description provided for @examQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'20 questions'**
  String get examQuestionCount;

  /// No description provided for @examQuestionCountDesc.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice with 4 options each'**
  String get examQuestionCountDesc;

  /// No description provided for @examPassingScore.
  ///
  /// In en, this message translates to:
  /// **'Passing score'**
  String get examPassingScore;

  /// No description provided for @examPassingScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'You need 70% or above to pass'**
  String get examPassingScoreDesc;

  /// No description provided for @examNoGoingBack.
  ///
  /// In en, this message translates to:
  /// **'No going back'**
  String get examNoGoingBack;

  /// No description provided for @examNoGoingBackDesc.
  ///
  /// In en, this message translates to:
  /// **'You cannot go back to previous questions'**
  String get examNoGoingBackDesc;

  /// No description provided for @examWarning.
  ///
  /// In en, this message translates to:
  /// **'Make sure you have a stable internet connection and won\'t be interrupted'**
  String get examWarning;

  /// No description provided for @examStartExam.
  ///
  /// In en, this message translates to:
  /// **'Start Exam'**
  String get examStartExam;

  /// No description provided for @examSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get examSubmit;

  /// No description provided for @examCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get examCongratulations;

  /// No description provided for @examGoodEffort.
  ///
  /// In en, this message translates to:
  /// **'Good effort'**
  String get examGoodEffort;

  /// No description provided for @examPassedMessage.
  ///
  /// In en, this message translates to:
  /// **'You passed the exam with flying colors!'**
  String get examPassedMessage;

  /// No description provided for @examFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing to improve your score'**
  String get examFailedMessage;

  /// No description provided for @examYourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get examYourScore;

  /// No description provided for @examCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get examCorrect;

  /// No description provided for @examAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get examAccuracy;

  /// No description provided for @examNeedMorePractice.
  ///
  /// In en, this message translates to:
  /// **'You need 70% to pass. Keep practicing!'**
  String get examNeedMorePractice;

  /// No description provided for @examBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned a badge for passing the exam!'**
  String get examBadgeEarned;

  /// No description provided for @examRetakeTest.
  ///
  /// In en, this message translates to:
  /// **'Retake Exam'**
  String get examRetakeTest;

  /// No description provided for @examBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get examBackHome;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressTitle;

  /// No description provided for @progressPerformanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Performance Summary'**
  String get progressPerformanceSummary;

  /// No description provided for @progressTotalAttempts.
  ///
  /// In en, this message translates to:
  /// **'Total Attempts'**
  String get progressTotalAttempts;

  /// No description provided for @progressBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get progressBestScore;

  /// No description provided for @progressAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get progressAverageScore;

  /// No description provided for @progressSignsLearned.
  ///
  /// In en, this message translates to:
  /// **'Signs Learned'**
  String get progressSignsLearned;

  /// No description provided for @progressRecentExams.
  ///
  /// In en, this message translates to:
  /// **'Recent Exams'**
  String get progressRecentExams;

  /// No description provided for @progressOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get progressOverall;

  /// No description provided for @progressComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get progressComplete;

  /// No description provided for @progressAvgScore.
  ///
  /// In en, this message translates to:
  /// **'Avg. score'**
  String get progressAvgScore;

  /// No description provided for @progressSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs'**
  String get progressSigns;

  /// No description provided for @progressPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get progressPassed;

  /// No description provided for @progressExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get progressExcellent;

  /// No description provided for @progressMockExam.
  ///
  /// In en, this message translates to:
  /// **'Practice Exam {number}'**
  String progressMockExam(Object number);

  /// No description provided for @progressPracticeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Practice Quiz'**
  String get progressPracticeQuiz;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLocation.
  ///
  /// In en, this message translates to:
  /// **'Kigali, Rwanda'**
  String get profileLocation;

  /// No description provided for @profileOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get profileOverallProgress;

  /// No description provided for @profileModulesCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} exams completed'**
  String profileModulesCompleted(Object completed, Object total);

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications, language, data'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account entirely? This action cannot be undone.'**
  String get profileDeleteConfirmMessage;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// No description provided for @certificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Certificates'**
  String get certificatesTitle;

  /// No description provided for @certificatesAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get certificatesAchievements;

  /// No description provided for @certificatesEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get certificatesEarned;

  /// No description provided for @certificatesPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get certificatesPending;

  /// No description provided for @certificatesInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get certificatesInProgress;

  /// No description provided for @certificateRoadSignsMastery.
  ///
  /// In en, this message translates to:
  /// **'Traffic sign mastery'**
  String get certificateRoadSignsMastery;

  /// No description provided for @certificateTrafficRulesTest.
  ///
  /// In en, this message translates to:
  /// **'Traffic rules test'**
  String get certificateTrafficRulesTest;

  /// No description provided for @certificateDefensiveDriving.
  ///
  /// In en, this message translates to:
  /// **'Defensive driving'**
  String get certificateDefensiveDriving;

  /// No description provided for @signsTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Signs'**
  String get signsTitle;

  /// No description provided for @signsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for traffic signs...'**
  String get signsSearchHint;

  /// No description provided for @signsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No traffic signs found'**
  String get signsNotFound;

  /// No description provided for @signsLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get signsLearned;

  /// No description provided for @signsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get signsAll;

  /// No description provided for @signDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic Sign'**
  String get signDetailTitle;

  /// No description provided for @signDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sign not found'**
  String get signDetailNotFound;

  /// No description provided for @signDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get signDetailDescription;

  /// No description provided for @signDetailScenario.
  ///
  /// In en, this message translates to:
  /// **'Real-life scenario'**
  String get signDetailScenario;

  /// No description provided for @signDetailLearned.
  ///
  /// In en, this message translates to:
  /// **'You learned this sign!'**
  String get signDetailLearned;

  /// No description provided for @signDetailMarkAsLearned.
  ///
  /// In en, this message translates to:
  /// **'Mark as learned'**
  String get signDetailMarkAsLearned;

  /// No description provided for @signDetailMarkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign marked as learned!'**
  String get signDetailMarkedSuccess;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Request exam access'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'request exam access'**
  String get subscriptionSubtitle;

  /// No description provided for @subscriptionTrafficRulesMsg.
  ///
  /// In en, this message translates to:
  /// **'If you want to learn traffic rules, contact us or send us a WhatsApp message and we will help you prepare well for your provisional license driving theory exam.'**
  String get subscriptionTrafficRulesMsg;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Your current plan'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No active plan'**
  String get subscriptionNoPlan;

  /// No description provided for @subscriptionMonth1.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get subscriptionMonth1;

  /// No description provided for @subscriptionMonth3.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get subscriptionMonth3;

  /// No description provided for @subscriptionMonth6.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get subscriptionMonth6;

  /// No description provided for @subscriptionPrice.
  ///
  /// In en, this message translates to:
  /// **'{amount} RWF'**
  String subscriptionPrice(Object amount);

  /// No description provided for @subscriptionRequestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get subscriptionRequestAccess;

  /// No description provided for @subscriptionRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent successfully.Wait a moment for them to see that you have been approved.'**
  String get subscriptionRequestSent;

  /// No description provided for @subscriptionPaymentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Payment instructions'**
  String get subscriptionPaymentInstructions;

  /// No description provided for @subscriptionPaymentMomo.
  ///
  /// In en, this message translates to:
  /// **'MoMo Pay: 329494'**
  String get subscriptionPaymentMomo;

  /// No description provided for @subscriptionPaymentMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money: 0788659575'**
  String get subscriptionPaymentMobile;

  /// No description provided for @subscriptionPaymentTigoCash.
  ///
  /// In en, this message translates to:
  /// **'Tigo Cash: 0728877442'**
  String get subscriptionPaymentTigoCash;

  /// No description provided for @subscriptionHelpCall.
  ///
  /// In en, this message translates to:
  /// **'Call: 0788659575'**
  String get subscriptionHelpCall;

  /// No description provided for @subscriptionHelpWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp: 0788659575'**
  String get subscriptionHelpWhatsapp;

  /// No description provided for @subscriptionChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose a learning plan'**
  String get subscriptionChoosePlan;

  /// No description provided for @subscriptionCurrency.
  ///
  /// In en, this message translates to:
  /// **'Months you want to learn'**
  String get subscriptionCurrency;

  /// No description provided for @subscriptionAccessActive.
  ///
  /// In en, this message translates to:
  /// **'Access available'**
  String get subscriptionAccessActive;

  /// No description provided for @subscriptionExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String subscriptionExpires(Object date);

  /// No description provided for @subscriptionDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String subscriptionDays(Object days);

  /// No description provided for @subscriptionNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get subscriptionNeedHelp;

  /// No description provided for @subscriptionGetAccess.
  ///
  /// In en, this message translates to:
  /// **'Get {count}+ exam practice access'**
  String subscriptionGetAccess(Object count);

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage Access'**
  String get adminAccess;

  /// No description provided for @adminProgress.
  ///
  /// In en, this message translates to:
  /// **'User Progress'**
  String get adminProgress;

  /// No description provided for @adminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// No description provided for @adminActiveSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get adminActiveSubscriptions;

  /// No description provided for @adminUsersByLanguage.
  ///
  /// In en, this message translates to:
  /// **'Users by Language'**
  String get adminUsersByLanguage;

  /// No description provided for @adminRecentRegistrations.
  ///
  /// In en, this message translates to:
  /// **'Recent Registrations'**
  String get adminRecentRegistrations;

  /// No description provided for @adminGrantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get adminGrantAccess;

  /// No description provided for @adminCallUser.
  ///
  /// In en, this message translates to:
  /// **'Call User'**
  String get adminCallUser;

  /// No description provided for @adminCallNotes.
  ///
  /// In en, this message translates to:
  /// **'Call Notes'**
  String get adminCallNotes;

  /// No description provided for @adminLastCalled.
  ///
  /// In en, this message translates to:
  /// **'Last Called'**
  String get adminLastCalled;

  /// No description provided for @adminNoAccess.
  ///
  /// In en, this message translates to:
  /// **'No Access'**
  String get adminNoAccess;

  /// No description provided for @adminHasAccess.
  ///
  /// In en, this message translates to:
  /// **'Has Access'**
  String get adminHasAccess;

  /// No description provided for @adminAccessExpired.
  ///
  /// In en, this message translates to:
  /// **'Access Expired'**
  String get adminAccessExpired;

  /// No description provided for @adminAccessExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String adminAccessExpires(Object date);

  /// No description provided for @adminSearchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get adminSearchUsers;

  /// No description provided for @adminFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// No description provided for @adminFilterHasAccess.
  ///
  /// In en, this message translates to:
  /// **'Has Access'**
  String get adminFilterHasAccess;

  /// No description provided for @adminFilterNoAccess.
  ///
  /// In en, this message translates to:
  /// **'No Access'**
  String get adminFilterNoAccess;

  /// No description provided for @adminManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get adminManageUsers;

  /// No description provided for @adminManageAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage Access'**
  String get adminManageAccess;

  /// No description provided for @adminViewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get adminViewProgress;

  /// No description provided for @adminRegistrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registered: {date}'**
  String adminRegistrationDate(Object date);

  /// No description provided for @adminEnterCallNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter call notes...'**
  String get adminEnterCallNotes;

  /// No description provided for @adminSubmitCall.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get adminSubmitCall;

  /// No description provided for @adminCallLogged.
  ///
  /// In en, this message translates to:
  /// **'Call logged successfully'**
  String get adminCallLogged;

  /// No description provided for @adminAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Access granted successfully'**
  String get adminAccessGranted;

  /// No description provided for @adminSelectTier.
  ///
  /// In en, this message translates to:
  /// **'Select Access Level'**
  String get adminSelectTier;

  /// No description provided for @adminCustomDays.
  ///
  /// In en, this message translates to:
  /// **'Custom Days'**
  String get adminCustomDays;

  /// No description provided for @adminPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount (RWF)'**
  String get adminPaymentAmount;

  /// No description provided for @adminEnterDays.
  ///
  /// In en, this message translates to:
  /// **'Enter number of days'**
  String get adminEnterDays;

  /// No description provided for @adminEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in RWF'**
  String get adminEnterAmount;

  /// No description provided for @adminOrCustom.
  ///
  /// In en, this message translates to:
  /// **'Or enter custom days'**
  String get adminOrCustom;

  /// No description provided for @adminPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending payment requests'**
  String get adminPendingRequests;

  /// No description provided for @adminAllUsersList.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get adminAllUsersList;

  /// No description provided for @adminInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get adminInvalidAmount;

  /// No description provided for @adminInvalidDays.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of days greater than 0'**
  String get adminInvalidDays;

  /// No description provided for @adminAccessRevoked.
  ///
  /// In en, this message translates to:
  /// **'Access revoked'**
  String get adminAccessRevoked;

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminNoUsers;

  /// No description provided for @examListTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get examListTitle;

  /// No description provided for @examFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get examFree;

  /// No description provided for @examPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get examPaid;

  /// No description provided for @examLocked.
  ///
  /// In en, this message translates to:
  /// **'locked'**
  String get examLocked;

  /// No description provided for @examQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String examQuestions(Object count);

  /// No description provided for @quizProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get quizProgress;

  /// No description provided for @quizAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered: {answered}/{total}'**
  String quizAnswered(Object answered, Object total);

  /// No description provided for @quizSubmitPractice.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam'**
  String get quizSubmitPractice;

  /// No description provided for @quizPrevious.
  ///
  /// In en, this message translates to:
  /// **'previous'**
  String get quizPrevious;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get quizNext;

  /// No description provided for @quizTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String quizTimeRemaining(Object time);

  /// No description provided for @quizResults.
  ///
  /// In en, this message translates to:
  /// **'Exam Results'**
  String get quizResults;

  /// No description provided for @quizPassed.
  ///
  /// In en, this message translates to:
  /// **'Passed!'**
  String get quizPassed;

  /// No description provided for @quizFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get quizFailed;

  /// No description provided for @quizQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(Object current, Object total);

  /// No description provided for @quizSubmitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Exam?'**
  String get quizSubmitConfirmTitle;

  /// No description provided for @quizSubmitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You have answered {answered} out of {total} questions. Are you sure you want to submit?'**
  String quizSubmitConfirmMessage(Object answered, Object total);

  /// No description provided for @quizTimeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! The practice exam has been submitted automatically.'**
  String get quizTimeUp;

  /// No description provided for @quizReviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get quizReviewAnswers;

  /// No description provided for @quizRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake Exam'**
  String get quizRetake;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get profileLanguage;

  /// No description provided for @profileRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered: {date}'**
  String profileRegistered(Object date);

  /// No description provided for @profileAccessStatus.
  ///
  /// In en, this message translates to:
  /// **'Access Status'**
  String get profileAccessStatus;

  /// No description provided for @profileExamHistory.
  ///
  /// In en, this message translates to:
  /// **'Exam History'**
  String get profileExamHistory;

  /// No description provided for @profileCallHistory.
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get profileCallHistory;

  /// No description provided for @paymentInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get paymentInstructionsTitle;

  /// No description provided for @paymentMomoPayNumber.
  ///
  /// In en, this message translates to:
  /// **'MoMo Pay: 329494'**
  String get paymentMomoPayNumber;

  /// No description provided for @paymentMomoPayDial.
  ///
  /// In en, this message translates to:
  /// **'To pay with MoMo Pay, dial: *182*8*1*329494*amount#'**
  String get paymentMomoPayDial;

  /// No description provided for @paymentMobileMoneyNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money: 0788659575'**
  String get paymentMobileMoneyNumber;

  /// No description provided for @paymentTigoCashNumber.
  ///
  /// In en, this message translates to:
  /// **'Tigo Cash: 0728877442'**
  String get paymentTigoCashNumber;

  /// No description provided for @paymentMobileMoneyDial.
  ///
  /// In en, this message translates to:
  /// **'To pay with Mobile Money, dial: *182*1*1*0788659575*amount#'**
  String get paymentMobileMoneyDial;

  /// No description provided for @paymentTigoCashDial.
  ///
  /// In en, this message translates to:
  /// **'To pay with Tigo Cash, dial: *182*1*1*0728877442*amount#'**
  String get paymentTigoCashDial;

  /// No description provided for @paymentHelpText.
  ///
  /// In en, this message translates to:
  /// **'Need help? Call or WhatsApp: 0788659575'**
  String get paymentHelpText;

  /// No description provided for @paymentHelpContact.
  ///
  /// In en, this message translates to:
  /// **'You can copy or call: 0788659575 or WhatsApp: 0788659575 for help.'**
  String get paymentHelpContact;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment request conflict. Please pay using the instructions provided here.'**
  String get paymentError;

  /// No description provided for @paymentCopyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy number'**
  String get paymentCopyNumber;

  /// No description provided for @paymentCallNumber.
  ///
  /// In en, this message translates to:
  /// **'Call 0788659575'**
  String get paymentCallNumber;

  /// No description provided for @paymentCallTigoNumber.
  ///
  /// In en, this message translates to:
  /// **'Call 0728877442'**
  String get paymentCallTigoNumber;

  /// No description provided for @paymentWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send message to WhatsApp'**
  String get paymentWhatsApp;

  /// No description provided for @paymentWhatsAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Request access to use the driving theory exam app'**
  String get paymentWhatsAppMessage;

  /// No description provided for @paymentRequestExists.
  ///
  /// In en, this message translates to:
  /// **'Payment request already sent. Wait a moment for them to help you or contact help numbers and send a WhatsApp message which will appear below the page'**
  String get paymentRequestExists;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @adminTierLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
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
  /// **'View, search and manage all users'**
  String get adminManageUsersDesc;

  /// No description provided for @adminAccessCodesDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage access codes and payment'**
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
  /// **'Manage the traffic rules platform'**
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

  /// No description provided for @examWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get examWrong;

  /// No description provided for @examTimeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get examTimeSpent;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out of your account?'**
  String get profileLogoutConfirmMessage;

  /// No description provided for @profileDeleteInstructions.
  ///
  /// In en, this message translates to:
  /// **'Before deleting your account:\n• All your answers will be deleted\n• Your subscription will be deleted\n• You will need to sign up again to use the app'**
  String get profileDeleteInstructions;

  /// No description provided for @progressExamsTaken.
  ///
  /// In en, this message translates to:
  /// **'Exams Taken'**
  String get progressExamsTaken;

  /// No description provided for @progressPassedCount.
  ///
  /// In en, this message translates to:
  /// **'Exams Passed'**
  String get progressPassedCount;

  /// No description provided for @progressFailedCount.
  ///
  /// In en, this message translates to:
  /// **'Exams Failed'**
  String get progressFailedCount;

  /// No description provided for @progressPassRate.
  ///
  /// In en, this message translates to:
  /// **'Pass Rate'**
  String get progressPassRate;

  /// No description provided for @progressNoExams.
  ///
  /// In en, this message translates to:
  /// **'No exams taken. Start taking exams!'**
  String get progressNoExams;

  /// No description provided for @certificateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for the real exam!'**
  String get certificateReadyTitle;

  /// No description provided for @certificateReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have completed {count} exams. You are ready for the driving license access exam.'**
  String certificateReadySubtitle(Object count);

  /// No description provided for @certificateIremboLink.
  ///
  /// In en, this message translates to:
  /// **'Apply for the government exam at irembo.gov.rw'**
  String get certificateIremboLink;

  /// No description provided for @certificateIremboDesc.
  ///
  /// In en, this message translates to:
  /// **'Click here to apply for the online government driving license theory exam'**
  String get certificateIremboDesc;

  /// No description provided for @certificateExamsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Pass {needed} more exams to get the certificate proving you are ready for the provisional license driving theory exam'**
  String certificateExamsNeeded(Object needed);

  /// No description provided for @certificateProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{passed} of {total} required exams'**
  String certificateProgressLabel(Object passed, Object total);

  /// No description provided for @adminSortAsc.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get adminSortAsc;

  /// No description provided for @adminSortDesc.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get adminSortDesc;

  /// No description provided for @adminFilterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get adminFilterToday;

  /// No description provided for @adminDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get adminDateRange;

  /// No description provided for @adminFilterRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminFilterRole;

  /// No description provided for @adminBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get adminBlockUser;

  /// No description provided for @adminUnblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get adminUnblockUser;

  /// No description provided for @adminDeleteUserAction.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminDeleteUserAction;

  /// No description provided for @adminBlockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block {name}? They will no longer be able to sign in.'**
  String adminBlockUserConfirm(Object name);

  /// No description provided for @adminDeleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} entirely? All their data will be deleted.'**
  String adminDeleteUserConfirm(Object name);

  /// No description provided for @adminUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked successfully'**
  String get adminUserBlocked;

  /// No description provided for @adminUserUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked successfully'**
  String get adminUserUnblocked;

  /// No description provided for @adminUserDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get adminUserDeleted;

  /// No description provided for @adminMustBlockFirst.
  ///
  /// In en, this message translates to:
  /// **'You must block the user first before deleting them.'**
  String get adminMustBlockFirst;

  /// No description provided for @adminBlockAccess.
  ///
  /// In en, this message translates to:
  /// **'Block Access'**
  String get adminBlockAccess;

  /// No description provided for @adminDeleteAccess.
  ///
  /// In en, this message translates to:
  /// **'Delete Access'**
  String get adminDeleteAccess;

  /// No description provided for @adminBlockAccessConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block access code? The user will no longer be able to use the app.'**
  String get adminBlockAccessConfirm;

  /// No description provided for @adminDeleteAccessConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this access code?'**
  String get adminDeleteAccessConfirm;

  /// No description provided for @adminAccessBlocked.
  ///
  /// In en, this message translates to:
  /// **'Access code blocked'**
  String get adminAccessBlocked;

  /// No description provided for @adminAccessDeleted.
  ///
  /// In en, this message translates to:
  /// **'Access code deleted'**
  String get adminAccessDeleted;

  /// No description provided for @adminPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String adminPage(Object page, Object total);

  /// No description provided for @adminLearningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language of Interest'**
  String get adminLearningLanguage;

  /// No description provided for @adminIsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get adminIsBlocked;

  /// No description provided for @adminIsActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminIsActive;

  /// No description provided for @generalCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get generalCopied;

  /// No description provided for @adminRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get adminRetry;

  /// No description provided for @languageSelectDescription.
  ///
  /// In en, this message translates to:
  /// **'You can change the language later in Settings.'**
  String get languageSelectDescription;

  /// No description provided for @languageSelectDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSelectDeviceLanguage;

  /// No description provided for @languageSelectHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language help'**
  String get languageSelectHelpTooltip;

  /// No description provided for @languageSelectMaybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get languageSelectMaybeLater;

  /// No description provided for @languageSelectHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Why choose a language?'**
  String get languageSelectHelpTitle;

  /// No description provided for @languageSelectHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Choosing a language makes text, icons, and voice prompts appear in your language. You can change the language later in Settings.'**
  String get languageSelectHelpContent;

  /// No description provided for @commonGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonGotIt;

  /// No description provided for @languageSelectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get languageSelectDialogTitle;

  /// No description provided for @examNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exam not found'**
  String get examNotFound;

  /// No description provided for @errorWithDetail.
  ///
  /// In en, this message translates to:
  /// **'Error: {detail}'**
  String errorWithDetail(Object detail);

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {detail}'**
  String errorUnexpected(Object detail);

  /// No description provided for @priceRwf.
  ///
  /// In en, this message translates to:
  /// **'{amount} RWF'**
  String priceRwf(Object amount);

  /// No description provided for @errorHttpStatus.
  ///
  /// In en, this message translates to:
  /// **'HTTP {code}'**
  String errorHttpStatus(Object code);

  /// No description provided for @examSampleQ1.
  ///
  /// In en, this message translates to:
  /// **'What is the maximum speed on a major road?'**
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

  /// No description provided for @examSampleQ2.
  ///
  /// In en, this message translates to:
  /// **'What does this traffic sign mean?'**
  String get examSampleQ2;

  /// No description provided for @examSampleQ2A1.
  ///
  /// In en, this message translates to:
  /// **'Stop right there'**
  String get examSampleQ2A1;

  /// No description provided for @examSampleQ2A2.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get examSampleQ2A2;

  /// No description provided for @examSampleQ2A3.
  ///
  /// In en, this message translates to:
  /// **'Prepare to stop'**
  String get examSampleQ2A3;

  /// No description provided for @examSampleQ2A4.
  ///
  /// In en, this message translates to:
  /// **'Change lane'**
  String get examSampleQ2A4;

  /// No description provided for @examSampleQ3.
  ///
  /// In en, this message translates to:
  /// **'How far can you park from a water fire hydrant?'**
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
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get examShareResult;

  /// No description provided for @examCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Results copied'**
  String get examCopiedToClipboard;

  /// No description provided for @examGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get examGradeLabel;

  /// No description provided for @subscriptionPopular.
  ///
  /// In en, this message translates to:
  /// **'★ Popular'**
  String get subscriptionPopular;

  /// No description provided for @quizTimeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Used'**
  String get quizTimeTaken;

  /// No description provided for @progressTotalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get progressTotalQuestions;

  /// No description provided for @progressCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Questions Correct'**
  String get progressCorrectAnswers;

  /// No description provided for @progressIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Questions Wrong'**
  String get progressIncorrect;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @paymentChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get paymentChooseMethod;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule'**
  String get aboutAppName;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule is your helper for learning traffic rules, traffic signs, and practicing exam questions to prepare for your provisional license driving theory exam. This is an independent educational app and is not affiliated with any government or testing center.'**
  String get aboutDescription;

  /// No description provided for @aboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get aboutFeatures;

  /// No description provided for @aboutFeaturePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice Exams'**
  String get aboutFeaturePractice;

  /// No description provided for @aboutFeatureProgress.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get aboutFeatureProgress;

  /// No description provided for @aboutFeatureMultilingual.
  ///
  /// In en, this message translates to:
  /// **'3 Languages'**
  String get aboutFeatureMultilingual;

  /// No description provided for @aboutFeatureCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get aboutFeatureCertificate;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get aboutContact;

  /// No description provided for @aboutContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Tel/WhatsApp: 0788659575 / 0728877442'**
  String get aboutContactInfo;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'App owner rights'**
  String get aboutCopyright;

  /// No description provided for @aboutCopyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Rwanda Traffic Rule. App owner rights reserved.'**
  String get aboutCopyrightText;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: February 2026'**
  String get privacyLastUpdated;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule cares about your privacy. These guidelines explain how we collect, use, and protect your data. We are an independent educational service and are not affiliated with any government agency.'**
  String get privacyIntro;

  /// No description provided for @privacyDataCollection.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get privacyDataCollection;

  /// No description provided for @privacyDataCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'We collect your phone number and full name when you sign up. We also collect your device fingerprint, which is a unique identifier used to protect your account. We collect your exam answers and progress data. A unique device ID is created to secure your account.'**
  String get privacyDataCollectionBody;

  /// No description provided for @privacyDataUsage.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Data'**
  String get privacyDataUsage;

  /// No description provided for @privacyDataUsageBody.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to provide and improve our services, track your progress, manage your subscriptions, and send you important information.'**
  String get privacyDataUsageBody;

  /// No description provided for @privacyDataProtection.
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get privacyDataProtection;

  /// No description provided for @privacyDataProtectionBody.
  ///
  /// In en, this message translates to:
  /// **'We use high-level security measures, including encrypted transmission and secure storage. Your personal data is never shared without your consent.'**
  String get privacyDataProtectionBody;

  /// No description provided for @privacyDataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get privacyDataSharing;

  /// No description provided for @privacyDataSharingBody.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal information to third parties. We may share anonymized data for statistical purposes.'**
  String get privacyDataSharingBody;

  /// No description provided for @privacyUserRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyUserRights;

  /// No description provided for @privacyUserRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data at any time through the Delete Account option in Settings.'**
  String get privacyUserRightsBody;

  /// No description provided for @termsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: February 2026'**
  String get termsLastUpdated;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'By using Rwanda Traffic Rule, you agree to the following terms. Rwanda Traffic Rule is an independent educational app that helps you prepare for your theory exam. We are not affiliated with any government or testing center.'**
  String get termsIntro;

  /// No description provided for @termsAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsAcceptance;

  /// No description provided for @termsAcceptanceBody.
  ///
  /// In en, this message translates to:
  /// **'By creating an account and using this app, you agree to these terms. If you do not agree, please stop using this app.'**
  String get termsAcceptanceBody;

  /// No description provided for @termsUserAccount.
  ///
  /// In en, this message translates to:
  /// **'User Account'**
  String get termsUserAccount;

  /// No description provided for @termsUserAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the security of your account. Each account is linked to one phone number and one device. Sharing account information is not allowed.'**
  String get termsUserAccountBody;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'Exam Content'**
  String get termsContent;

  /// No description provided for @termsContentBody.
  ///
  /// In en, this message translates to:
  /// **'All exam questions are for practice and education only. They are not a substitute for the official government exam. We cannot guarantee exam results. Rwanda Traffic Rule is not affiliated with any government agency.'**
  String get termsContentBody;

  /// No description provided for @termsPayment.
  ///
  /// In en, this message translates to:
  /// **'Requesting Exam Access'**
  String get termsPayment;

  /// No description provided for @termsPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'To access the app, contact help at 0788659575 or 0728877442.'**
  String get termsPaymentBody;

  /// No description provided for @termsTermination.
  ///
  /// In en, this message translates to:
  /// **'Account Closure'**
  String get termsTermination;

  /// No description provided for @termsTerminationBody.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to close accounts that violate these terms. You may delete your account at any time in Settings.'**
  String get termsTerminationBody;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get aboutDisclaimer;

  /// No description provided for @aboutDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule is an independent educational app that helps you learn traffic rules and prepare for your theory exam. This app is not affiliated with, endorsed by, or connected to any government agency or testing center. All content in this app is for practice and education only.'**
  String get aboutDisclaimerText;

  /// No description provided for @profileCertificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get profileCertificatesTitle;

  /// No description provided for @profileCertificatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates earned and progress to next'**
  String get profileCertificatesSubtitle;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Cached data may not be up to date.'**
  String get offlineBanner;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncingData;

  /// No description provided for @dataSynced.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get dataSynced;

  /// No description provided for @savedOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. Will sync when you reconnect to the internet.'**
  String get savedOffline;

  /// No description provided for @certificateUniqueExamsPassed.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} unique exams passed'**
  String certificateUniqueExamsPassed(Object count, Object total);

  /// No description provided for @certificatePassMark.
  ///
  /// In en, this message translates to:
  /// **'Passing score: {required}/{total} ({percent}%)'**
  String certificatePassMark(Object percent, Object required, Object total);

  /// No description provided for @certificateLatestAttempt.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get certificateLatestAttempt;

  /// No description provided for @certificateExamStatus.
  ///
  /// In en, this message translates to:
  /// **'Exam {index}'**
  String certificateExamStatus(Object index);

  /// No description provided for @certificateNotAttempted.
  ///
  /// In en, this message translates to:
  /// **'Not attempted'**
  String get certificateNotAttempted;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your survey is important'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'Rwanda Traffic Rule collects and works with the following information to give you the best learning experience:\n\n• Phone number and name — to open an account and verify\n• Device fingerprint — a unique identifier assigned by a hash to protect your account\n• Exam answers and progress — to track your learning journey\n• Offline cache — so the app works without internet\n\nYour data is securely stored and never leaked to others. You can delete your account and all associated data at any time using the profile settings.'**
  String get consentBody;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand and agree'**
  String get consentAccept;

  /// No description provided for @consentReadPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read Privacy Policy'**
  String get consentReadPolicy;

  /// No description provided for @registerInvalidName.
  ///
  /// In en, this message translates to:
  /// **'Name must contain only letters and spaces'**
  String get registerInvalidName;

  /// No description provided for @registerInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (e.g., 078... or +250 78...)'**
  String get registerInvalidPhone;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Group'**
  String get joinGroup;

  /// No description provided for @joinGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join WhatsApp group'**
  String get joinGroupSubtitle;

  /// No description provided for @adminOfflineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Offline – show cached data'**
  String get adminOfflineTooltip;

  /// No description provided for @adminOfflineBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get adminOfflineBadge;

  /// No description provided for @adminActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String adminActiveLabel(Object count);

  /// No description provided for @adminFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminFallbackName;

  /// No description provided for @adminNoNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No network. No cached data available.'**
  String get adminNoNetworkError;

  /// No description provided for @commonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonErrorTitle;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit app'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the app?'**
  String get exitAppMessage;

  /// No description provided for @exitAppYes.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitAppYes;

  /// No description provided for @exitAppNo.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get exitAppNo;

  /// No description provided for @consentItemPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number and name'**
  String get consentItemPhone;

  /// No description provided for @consentItemPhoneDetail.
  ///
  /// In en, this message translates to:
  /// **'Open account and verify'**
  String get consentItemPhoneDetail;

  /// No description provided for @consentItemDevice.
  ///
  /// In en, this message translates to:
  /// **'Device fingerprint'**
  String get consentItemDevice;

  /// No description provided for @consentItemDeviceDetail.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier used to protect your account'**
  String get consentItemDeviceDetail;

  /// No description provided for @consentItemProgress.
  ///
  /// In en, this message translates to:
  /// **'Exam answers and progress'**
  String get consentItemProgress;

  /// No description provided for @consentItemProgressDetail.
  ///
  /// In en, this message translates to:
  /// **'Track your learning journey'**
  String get consentItemProgressDetail;

  /// No description provided for @consentItemCache.
  ///
  /// In en, this message translates to:
  /// **'Offline cache'**
  String get consentItemCache;

  /// No description provided for @consentItemCacheDetail.
  ///
  /// In en, this message translates to:
  /// **'App works without internet'**
  String get consentItemCacheDetail;

  /// No description provided for @consentSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is securely stored and never leaked to others.'**
  String get consentSecurityNote;

  /// No description provided for @consentIndependentTitle.
  ///
  /// In en, this message translates to:
  /// **'Independent content'**
  String get consentIndependentTitle;

  /// No description provided for @consentIndependentBody.
  ///
  /// In en, this message translates to:
  /// **'This is an independent educational app. It is not affiliated with, endorsed by, or connected to any government or police level.'**
  String get consentIndependentBody;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get dashboardWelcome;

  /// No description provided for @dashboardNotices.
  ///
  /// In en, this message translates to:
  /// **'NOTICES'**
  String get dashboardNotices;

  /// No description provided for @dashboardWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Group'**
  String get dashboardWhatsapp;

  /// No description provided for @dashboardGazette.
  ///
  /// In en, this message translates to:
  /// **'NEW GAZETTE'**
  String get dashboardGazette;

  /// No description provided for @dashboardShare.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get dashboardShare;

  /// No description provided for @dashboardProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account info unavailable'**
  String get dashboardProfileUnavailable;

  /// No description provided for @dashboardLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading access info…'**
  String get dashboardLoading;

  /// No description provided for @dashboardSubscriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Access info unavailable. Pull down to retry.'**
  String get dashboardSubscriptionUnavailable;

  /// No description provided for @dashboardExpired.
  ///
  /// In en, this message translates to:
  /// **'Learning access expired'**
  String get dashboardExpired;

  /// No description provided for @dashboardDurationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get dashboardDurationUnavailable;

  /// No description provided for @dashboardDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration: {duration}'**
  String dashboardDuration(Object duration);

  /// No description provided for @dashboardCached.
  ///
  /// In en, this message translates to:
  /// **'Cached data · pull to refresh'**
  String get dashboardCached;

  /// No description provided for @dashboardNoticesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notices unavailable now. Try again later.'**
  String get dashboardNoticesUnavailable;

  /// No description provided for @dashboardNoNotices.
  ///
  /// In en, this message translates to:
  /// **'No notices'**
  String get dashboardNoNotices;

  /// No description provided for @dashboardCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get dashboardCopyLink;

  /// No description provided for @dashboardLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get dashboardLinkCopied;

  /// No description provided for @dashboardOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unavailable. Try again.'**
  String get dashboardOpenFailed;

  /// No description provided for @dashboardComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get dashboardComingSoon;

  /// No description provided for @dashboardUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development.'**
  String get dashboardUnderDevelopment;

  /// No description provided for @dashboardExamsLocked.
  ///
  /// In en, this message translates to:
  /// **'Exams locked'**
  String get dashboardExamsLocked;

  /// No description provided for @dashboardRequestExamAccess.
  ///
  /// In en, this message translates to:
  /// **'Request exam access here'**
  String get dashboardRequestExamAccess;

  /// No description provided for @paymentExamLanguage.
  ///
  /// In en, this message translates to:
  /// **'Exam language'**
  String get paymentExamLanguage;

  /// No description provided for @paymentExamLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Choose exam language. This does not change app language.'**
  String get paymentExamLanguageHint;

  /// No description provided for @paymentAmountToPay.
  ///
  /// In en, this message translates to:
  /// **'Amount to pay: {amount} RWF'**
  String paymentAmountToPay(Object amount);

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// No description provided for @paymentNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Payment info not configured.'**
  String get paymentNotConfigured;

  /// No description provided for @paymentUssdLabel.
  ///
  /// In en, this message translates to:
  /// **'USSD dial code'**
  String get paymentUssdLabel;

  /// No description provided for @paymentCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get paymentCopyCode;

  /// No description provided for @paymentCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get paymentCodeCopied;

  /// No description provided for @paymentCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Code not copied. Try again or copy manually.'**
  String get paymentCopyFailed;

  /// No description provided for @paymentUssdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Copy this code and use it on your phone to pay.'**
  String get paymentUssdInstruction;

  /// No description provided for @paymentPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get paymentPayNow;

  /// No description provided for @paymentIntegrationPending.
  ///
  /// In en, this message translates to:
  /// **'Payment info pending. Payment initiation method not connected; no payment approved.'**
  String get paymentIntegrationPending;

  /// No description provided for @paymentPreparationFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment preparation failed. Try again.'**
  String get paymentPreparationFailed;

  /// No description provided for @paymentRecipient.
  ///
  /// In en, this message translates to:
  /// **'{method} teacher: {name}'**
  String paymentRecipient(Object method, Object name);

  /// No description provided for @paymentVerifyRecipient.
  ///
  /// In en, this message translates to:
  /// **'Before confirming payment, check that the recipient name shown on your phone matches what you entered here. If not, do not proceed.'**
  String paymentVerifyRecipient(Object name);

  /// No description provided for @dashboardGazetteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Traffic rules'**
  String get dashboardGazetteSubtitle;

  /// No description provided for @dashboardIremboSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Irembo services'**
  String get dashboardIremboSubtitle;

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'GUIDELINES'**
  String get guideTitle;

  /// No description provided for @guideWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to RWANDA TRAFFIC RULE'**
  String get guideWelcome;

  /// No description provided for @guideAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'1. App description'**
  String get guideAboutTitle;

  /// No description provided for @guideAboutBody.
  ///
  /// In en, this message translates to:
  /// **'This app called ``RWANDA TRAFFIC RULE`` is an app that teaches traffic rules, consisting of questions asked in the provisional exam (learner permit)'**
  String get guideAboutBody;

  /// No description provided for @guideUseTitle.
  ///
  /// In en, this message translates to:
  /// **'2. HOW THE APP WORKS'**
  String get guideUseTitle;

  /// No description provided for @guideUseBody.
  ///
  /// In en, this message translates to:
  /// **'1. To use this app you must first sign up when you first download it where you are asked to write your full name, your phone number; confirm and sign up approved\n\n2. When you already signed up you do not need to sign up again but instead sign up \\\"SIGN IN\\\" then you can enter your phone number then sign up \\\"APPROVED\\\" then you will be taken to dashboard where you will see items in the app.\n\n3. To start learning, sign up \\\"PRACTICE\\\" when you open it consists of 21 exams each consisting of 20 questions, but the first exam is free (free) the rest require payment.\n\n4. When you are practicing in this app, the row you make changes from green to red and when you mark it changes from green to red because practice always shows the correct answer so you can try to capture it (remember it) then sign up written \\\"NEXT\\\" go to the next question when you reach the end sign up written \\\"SUBMIT EXAM\\\" then you will see the score then choose another exam to learn'**
  String get guideUseBody;

  /// No description provided for @guideExamTitle.
  ///
  /// In en, this message translates to:
  /// **'3. HOW YOU SEE QUESTIONS ON THE PROVISOIRE EXAM NYIRIZINA'**
  String get guideExamTitle;

  /// No description provided for @guideExamBody.
  ///
  /// In en, this message translates to:
  /// **'A. Go to the provisoireform on the machine First they will assess (evaluate) that you do not have disability, vision, hearing, reading and writing skills, proper identification number (identification) and that day\'s code, many others,... example fingerprint, on the thumb left index,...\n\nB. You will see these questions in this app as they are in the exam no questions they will ask you in the provisoire exam that are not in this app, If you choose an answer you will continue then the next question then you sign up \\\"NEXT\\\" continue with other questions when you finish you sign up \\\"SUBMIT EXAM\\\" then you will know the score so choose another exam to learn'**
  String get guideExamBody;

  /// No description provided for @guidePaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'4. PAY TO UNLOCK ALL EXAMS'**
  String get guidePaymentTitle;

  /// No description provided for @guidePaymentBody.
  ///
  /// In en, this message translates to:
  /// **'1. As I explained earlier the first exam is free the other 20 require payment 1500Rwf to learn one month, 3000Rwf to learn three months or 5000 Rwf to learn six months on 0788659575/ 0728877442 or on MOMO PAY: 329494 merchant Alexis.\n\nTo pay using any number you choose is valid not mandatory to mention but if you use another number when you finish paying you will receive a message\n\nA. Pay using MTN:\na. *182*1*1*0788659575*1500#\nb. *182*8*1*329494*1500#\n\nB. Pay using Tigo or Airtel\na. *500*1*1*0728877442*1500#\nb. *182*8*1*88329494*1500#\nMerchant Alexis\n\n2. When you finish paying go check if you have connection (internet) wait two minutes then sign in before writing language on the screen then open practice you will see them unlocked all of them.\n\n4. OTHER MEANINGS THAT CAUSED YOU TO RECEIVE A MESSAGE:'**
  String get guidePaymentBody;

  /// No description provided for @guideOpenAccess.
  ///
  /// In en, this message translates to:
  /// **'View payment prices'**
  String get guideOpenAccess;

  /// No description provided for @dashboardRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh access'**
  String get dashboardRefresh;

  /// No description provided for @dashboardRefreshDone.
  ///
  /// In en, this message translates to:
  /// **'Access refreshed.'**
  String get dashboardRefreshDone;

  /// No description provided for @dashboardRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh access. Check your internet and try again.'**
  String get dashboardRefreshFailed;

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesTitle;

  /// No description provided for @resourcesDescription.
  ///
  /// In en, this message translates to:
  /// **'Read gazette and signs in the app. These resources are included and readable without internet; choose your preferred language.'**
  String get resourcesDescription;

  /// No description provided for @resourcesGazette.
  ///
  /// In en, this message translates to:
  /// **'Gazette'**
  String get resourcesGazette;

  /// No description provided for @resourcesRoadSigns.
  ///
  /// In en, this message translates to:
  /// **'Signs'**
  String get resourcesRoadSigns;

  /// No description provided for @resourcesOfflinePdf.
  ///
  /// In en, this message translates to:
  /// **'PDF • Read offline'**
  String get resourcesOfflinePdf;

  /// No description provided for @resourcesReadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to open this resource. Try again.'**
  String get resourcesReadError;

  /// No description provided for @resourcesPreviousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get resourcesPreviousPage;

  /// No description provided for @resourcesNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get resourcesNextPage;

  /// No description provided for @resourcesZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get resourcesZoomOut;

  /// No description provided for @resourcesZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get resourcesZoomIn;

  /// No description provided for @resourcesLoading.
  ///
  /// In en, this message translates to:
  /// **'Resource loading…'**
  String get resourcesLoading;

  /// No description provided for @resourcesPageCount.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String resourcesPageCount(Object page, Object total);

  /// No description provided for @irTitle.
  ///
  /// In en, this message translates to:
  /// **'Irembo services'**
  String get irTitle;

  /// No description provided for @irAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request submitted. One request per service.'**
  String get irAlreadySubmitted;

  /// No description provided for @permisOption.
  ///
  /// In en, this message translates to:
  /// **'Permis option'**
  String get permisOption;

  /// No description provided for @irOption.
  ///
  /// In en, this message translates to:
  /// **'Irembo option'**
  String get irOption;

  /// No description provided for @irServiceFee.
  ///
  /// In en, this message translates to:
  /// **'Registration assistance fee'**
  String get irServiceFee;

  /// No description provided for @irPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get irPay;

  /// No description provided for @irWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Irembo request'**
  String get irWorkspace;

  /// No description provided for @irMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My Irembo requests'**
  String get irMyRequests;

  /// No description provided for @irNew.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get irNew;

  /// No description provided for @irManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get irManual;

  /// No description provided for @irAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get irAutomatic;

  /// No description provided for @irNotice.
  ///
  /// In en, this message translates to:
  /// **'Help with exam registration. Registration is approved automatically.'**
  String get irNotice;

  /// No description provided for @irFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get irFullName;

  /// No description provided for @irPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get irPhone;

  /// No description provided for @irNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get irNationalId;

  /// No description provided for @irDob.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get irDob;

  /// No description provided for @irExamLanguage.
  ///
  /// In en, this message translates to:
  /// **'Exam language'**
  String get irExamLanguage;

  /// No description provided for @irLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Kinyarwanda, English, French'**
  String get irLanguageHint;

  /// No description provided for @irDistrict.
  ///
  /// In en, this message translates to:
  /// **'District where you want the exam done'**
  String get irDistrict;

  /// No description provided for @irExamDate.
  ///
  /// In en, this message translates to:
  /// **'Preferred exam date (optional)'**
  String get irExamDate;

  /// No description provided for @irDateNotice.
  ///
  /// In en, this message translates to:
  /// **'Preferred date is not the exam itinerary.'**
  String get irDateNotice;

  /// No description provided for @irProvisoireCode.
  ///
  /// In en, this message translates to:
  /// **'Provisoire code'**
  String get irProvisoireCode;

  /// No description provided for @irCategory.
  ///
  /// In en, this message translates to:
  /// **'Applicant category'**
  String get irCategory;

  /// No description provided for @irService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get irService;

  /// No description provided for @irSelectRequest.
  ///
  /// In en, this message translates to:
  /// **'Choose request'**
  String get irSelectRequest;

  /// No description provided for @irReview.
  ///
  /// In en, this message translates to:
  /// **'Review request'**
  String get irReview;

  /// No description provided for @irConfirm.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get irConfirm;

  /// No description provided for @irEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit request'**
  String get irEdit;

  /// No description provided for @irSaved.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get irSaved;

  /// No description provided for @irReference.
  ///
  /// In en, this message translates to:
  /// **'Request number'**
  String get irReference;

  /// No description provided for @irStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get irStatus;

  /// No description provided for @irSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted time'**
  String get irSubmitted;

  /// No description provided for @irUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated time'**
  String get irUpdated;

  /// No description provided for @irAssigned.
  ///
  /// In en, this message translates to:
  /// **'Staff assigned'**
  String get irAssigned;

  /// No description provided for @irUnassigned.
  ///
  /// In en, this message translates to:
  /// **'No staff assigned'**
  String get irUnassigned;

  /// No description provided for @irPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get irPending;

  /// No description provided for @irInReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get irInReview;

  /// No description provided for @irNeedsInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing information'**
  String get irNeedsInformation;

  /// No description provided for @irCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get irCompleted;

  /// No description provided for @irRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get irRejected;

  /// No description provided for @irCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get irCancelled;

  /// No description provided for @irSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone or ID'**
  String get irSearch;

  /// No description provided for @irFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get irFilters;

  /// No description provided for @irApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get irApply;

  /// No description provided for @irClear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get irClear;

  /// No description provided for @irAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get irAll;

  /// No description provided for @irFrom.
  ///
  /// In en, this message translates to:
  /// **'Submitted from'**
  String get irFrom;

  /// No description provided for @irTo.
  ///
  /// In en, this message translates to:
  /// **'Submitted to'**
  String get irTo;

  /// No description provided for @irNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get irNewest;

  /// No description provided for @irOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get irOldest;

  /// No description provided for @irSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get irSort;

  /// No description provided for @irEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching request'**
  String get irEmpty;

  /// No description provided for @irView.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get irView;

  /// No description provided for @irCall.
  ///
  /// In en, this message translates to:
  /// **'Call applicant'**
  String get irCall;

  /// No description provided for @irCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get irCopy;

  /// No description provided for @irCopyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy applicant details'**
  String get irCopyAll;

  /// No description provided for @irCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get irCopied;

  /// No description provided for @irCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy failed. Try again.'**
  String get irCopyFailed;

  /// No description provided for @irCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Call substitution app failed to open.'**
  String get irCallFailed;

  /// No description provided for @irMessages.
  ///
  /// In en, this message translates to:
  /// **'Message required for applicant'**
  String get irMessages;

  /// No description provided for @irInternalNotes.
  ///
  /// In en, this message translates to:
  /// **'Staff only notes'**
  String get irInternalNotes;

  /// No description provided for @irInternalHint.
  ///
  /// In en, this message translates to:
  /// **'Visible to staff only'**
  String get irInternalHint;

  /// No description provided for @irMessage.
  ///
  /// In en, this message translates to:
  /// **'Submitted message to applicant'**
  String get irMessage;

  /// No description provided for @irReason.
  ///
  /// In en, this message translates to:
  /// **'Reason (shows applicant)'**
  String get irReason;

  /// No description provided for @irReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Provide reason for pending request.'**
  String get irReasonRequired;

  /// No description provided for @irAudit.
  ///
  /// In en, this message translates to:
  /// **'Change history'**
  String get irAudit;

  /// No description provided for @irSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get irSave;

  /// No description provided for @irRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get irRetry;

  /// No description provided for @irClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get irClose;

  /// No description provided for @irRequired.
  ///
  /// In en, this message translates to:
  /// **'These fields are required.'**
  String get irRequired;

  /// No description provided for @irInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the info you entered.'**
  String get irInvalid;

  /// No description provided for @irInvalidId.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 16 digits.'**
  String get irInvalidId;

  /// No description provided for @irInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Rwandan phone number.'**
  String get irInvalidPhone;

  /// No description provided for @irUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot access this service. Check internet and try again. Info entered was lost.'**
  String get irUnavailable;

  /// No description provided for @irConflict.
  ///
  /// In en, this message translates to:
  /// **'This request was edited or submitted. Refresh the list before responding.'**
  String get irConflict;

  /// No description provided for @irNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get irNext;

  /// No description provided for @irPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get irPrevious;

  /// No description provided for @irCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created'**
  String get irCreated;

  /// No description provided for @irChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get irChange;

  /// No description provided for @irNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No message received.'**
  String get irNoMessages;

  /// No description provided for @irResults.
  ///
  /// In en, this message translates to:
  /// **'Results found'**
  String get irResults;

  /// No description provided for @irSelectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Search district'**
  String get irSelectDistrict;

  /// No description provided for @irEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get irEnglish;

  /// No description provided for @irFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get irFrench;

  /// No description provided for @irKinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get irKinyarwanda;

  /// No description provided for @irChooseService.
  ///
  /// In en, this message translates to:
  /// **'Choose exam service'**
  String get irChooseService;

  /// No description provided for @irChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose permit type'**
  String get irChooseOption;

  /// No description provided for @irProvisoireHelp.
  ///
  /// In en, this message translates to:
  /// **'Provisional learner permit exam'**
  String get irProvisoireHelp;

  /// No description provided for @irPermisHelp.
  ///
  /// In en, this message translates to:
  /// **'Provisional learner permit exam'**
  String get irPermisHelp;

  /// No description provided for @irContinue.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get irContinue;

  /// No description provided for @irRequestsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your request is unavailable.'**
  String get irRequestsUnavailable;

  /// No description provided for @irServerSetup.
  ///
  /// In en, this message translates to:
  /// **'Registration service not properly set up on server. Contact support or try again later.'**
  String get irServerSetup;

  /// No description provided for @irServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Registration service currently unavailable. Try again.'**
  String get irServiceUnavailable;

  /// No description provided for @irAccessUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not authorized to view this bureau. Check your signed-in account.'**
  String get irAccessUnavailable;

  /// No description provided for @irNoRequests.
  ///
  /// In en, this message translates to:
  /// **'Choose a service to begin.'**
  String get irNoRequests;

  /// No description provided for @irStaffHelp.
  ///
  /// In en, this message translates to:
  /// **'Search applicants, review request and track registration help.'**
  String get irStaffHelp;

  /// No description provided for @waIntro.
  ///
  /// In en, this message translates to:
  /// **'Let\'s build together. Choose a group to discuss questions and get study tips.'**
  String get waIntro;

  /// No description provided for @waManageIntro.
  ///
  /// In en, this message translates to:
  /// **'Manage study groups for students.'**
  String get waManageIntro;

  /// No description provided for @waCached.
  ///
  /// In en, this message translates to:
  /// **'These are cached groups. Joining a group or receiving new messages requires internet.'**
  String get waCached;

  /// No description provided for @progressSaved.
  ///
  /// In en, this message translates to:
  /// **'These are cached scores on this device. New scores will sync when internet is available.'**
  String get progressSaved;

  /// No description provided for @irDeleteRequest.
  ///
  /// In en, this message translates to:
  /// **'Delete request'**
  String get irDeleteRequest;

  /// No description provided for @irDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this request and its message permanently? This cannot be undone.'**
  String get irDeleteConfirm;

  /// No description provided for @irSelectPage.
  ///
  /// In en, this message translates to:
  /// **'Choose all requests on this page'**
  String get irSelectPage;

  /// No description provided for @irSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get irSelected;

  /// No description provided for @irDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get irDeleteSelected;

  /// No description provided for @irOfflineSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved request. Connect to internet to refresh, submit or delete request.'**
  String get irOfflineSaved;

  /// No description provided for @irDeleteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Deletion unavailable on this server. Update Irembo backend routes and handler, then retry.'**
  String get irDeleteUnavailable;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referralTitle;

  /// No description provided for @referralHeading.
  ///
  /// In en, this message translates to:
  /// **'Better prepared, together.'**
  String get referralHeading;

  /// No description provided for @referralDescription.
  ///
  /// In en, this message translates to:
  /// **'Help a friend prepare for their driving theory exam. Send your personal invitation and follow successful registrations here.'**
  String get referralDescription;

  /// No description provided for @referralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends. Track your invitations.'**
  String get referralSubtitle;

  /// No description provided for @referralYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your personal invitation code'**
  String get referralYourCode;

  /// No description provided for @referralCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String referralCodeLabel(Object code);

  /// No description provided for @referralInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get referralInvite;

  /// No description provided for @referralCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy referral link'**
  String get referralCopy;

  /// No description provided for @referralHistory.
  ///
  /// In en, this message translates to:
  /// **'Referral history'**
  String get referralHistory;

  /// No description provided for @referralTotal.
  ///
  /// In en, this message translates to:
  /// **'Total referrals'**
  String get referralTotal;

  /// No description provided for @referralConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Successful registration'**
  String get referralConfirmed;

  /// No description provided for @referralPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get referralPending;

  /// No description provided for @referralRewardsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Referral tracking is active. Rewards are not configured yet, so invitations do not currently grant money or exam access.'**
  String get referralRewardsDisabled;

  /// No description provided for @referralEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your invitations will appear here when friends create their accounts using your link.'**
  String get referralEmpty;

  /// No description provided for @referralLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your invitations. Check your connection and try again.'**
  String get referralLoadError;

  /// No description provided for @referralInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Prepare for your Rwanda driving theory exam with Rwanda Traffic Rules! Get the app and start learning using my invitation:'**
  String get referralInviteMessage;

  /// No description provided for @referralShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing isn’t available here. Use Copy referral link to send your invitation.'**
  String get referralShareUnavailable;

  /// No description provided for @referralMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get referralMore;

  /// No description provided for @adminReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get adminReferrals;

  /// No description provided for @adminReferralSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, referral code or phone'**
  String get adminReferralSearch;

  /// No description provided for @adminReferralInvitees.
  ///
  /// In en, this message translates to:
  /// **'Invited users'**
  String get adminReferralInvitees;

  /// No description provided for @adminReferralDeletedUser.
  ///
  /// In en, this message translates to:
  /// **'Deleted account'**
  String get adminReferralDeletedUser;

  /// No description provided for @dashboardReferrals.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get dashboardReferrals;

  /// No description provided for @authRecoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover account on this device'**
  String get authRecoverTitle;

  /// No description provided for @authRecoverBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is linked to another device. Enter your full name to move this account to this phone.'**
  String get authRecoverBody;

  /// No description provided for @authRecoverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authRecoverNameLabel;

  /// No description provided for @authRecoverConfirm.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get authRecoverConfirm;

  /// No description provided for @authRecoverNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name to recover this account.'**
  String get authRecoverNameRequired;

  /// No description provided for @authMoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Move account to this device'**
  String get authMoveTitle;

  /// No description provided for @authMoveBody.
  ///
  /// In en, this message translates to:
  /// **'This phone number already exists on another device. Do you want to move that account to this phone?'**
  String get authMoveBody;

  /// No description provided for @authMoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Move account'**
  String get authMoveConfirm;

  /// No description provided for @authMoveDetailsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name and phone number to recover this account.'**
  String get authMoveDetailsRequired;

  /// No description provided for @languageConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm language'**
  String get languageConfirmLabel;

  /// No description provided for @profileUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get profileUserNotFound;

  /// No description provided for @profileUserLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user'**
  String get profileUserLoadFailed;

  /// No description provided for @referralNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get referralNotAuthenticated;

  /// No description provided for @waLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load WhatsApp groups. Check your internet connection and try again.'**
  String get waLoadError;

  /// No description provided for @waAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add WhatsApp group'**
  String get waAddTitle;

  /// No description provided for @waEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit WhatsApp group'**
  String get waEditTitle;

  /// No description provided for @waGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get waGroupName;

  /// No description provided for @waNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get waNameRequired;

  /// No description provided for @waInviteLink.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp invite link'**
  String get waInviteLink;

  /// No description provided for @waInviteLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid WhatsApp invite link'**
  String get waInviteLinkInvalid;

  /// No description provided for @waCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get waCancel;

  /// No description provided for @waSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get waSave;

  /// No description provided for @waSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save group'**
  String get waSaveError;

  /// No description provided for @waDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete group?'**
  String get waDeleteTitle;

  /// No description provided for @waDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get waDelete;

  /// No description provided for @waDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete group'**
  String get waDeleteError;

  /// No description provided for @waEmpty.
  ///
  /// In en, this message translates to:
  /// **'No WhatsApp groups available yet.'**
  String get waEmpty;

  /// No description provided for @waOpenError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open group'**
  String get waOpenError;

  /// No description provided for @waEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get waEditTooltip;
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
      <String>['en', 'fr', 'rw', 'sw'].contains(locale.languageCode);

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
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
