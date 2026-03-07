// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Traffic Rules Learning App';

  @override
  String get languageSelectTitle => 'Choose Your Language';

  @override
  String get languageSelectSubtitle => 'You can change this later in Settings';

  @override
  String get languageSelectConfirm => 'Continue';

  @override
  String get homeWelcomeBack => 'Welcome back 👋';

  @override
  String homeGreeting(String userName) {
    return '$userName';
  }

  @override
  String get homeContinueMessage => 'Continue mastering traffic rules today.';

  @override
  String get homeContinueLearning => 'Continue Learning';

  @override
  String homeAccessActive(int daysLeft) {
    return 'Access Active - $daysLeft days left';
  }

  @override
  String homePaymentTier(String tier) {
    return 'Payment Tier: $tier';
  }

  @override
  String homePracticeSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count practice sessions',
      one: '1 practice session',
      zero: 'No practice sessions',
    );
    return '$_temp0';
  }

  @override
  String get homePractices => 'Practices';

  @override
  String get homePracticesSubtitle => 'Practice questions';

  @override
  String get homeCourses => 'Courses';

  @override
  String get homeCoursesSubtitle => 'Learning modules';

  @override
  String get homeMockExams => 'Mock Exams';

  @override
  String get homeMockExamsSubtitle => 'Test knowledge';

  @override
  String get homeProgress => 'Progress';

  @override
  String get homeProgressSubtitle => 'Track performance';

  @override
  String get homeShareApp => 'Share App';

  @override
  String get homeShareAppSubtitle => 'Invite friends';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeSubtitle => 'Use dark theme';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Receive daily reminders';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'About Traffic Rules App';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTermsOfServiceSubtitle => 'Read our terms';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsResetProgress => 'Reset Progress';

  @override
  String get settingsResetProgressSubtitle => 'Clear all your data';

  @override
  String get settingsResetConfirmTitle => 'Reset Progress';

  @override
  String get settingsResetConfirmMessage =>
      'Are you sure you want to reset all your progress? This action cannot be undone.';

  @override
  String get settingsResetSuccess => 'Progress reset successfully';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonReset => 'Reset';

  @override
  String get landingHeroTitle => 'Master Traffic Rules Easily';

  @override
  String get landingHeroSubtitle =>
      'Prepare smarter. Practice real exam questions. Track your progress and pass your driving license exam with confidence.';

  @override
  String get landingGetStarted => 'Get Started';

  @override
  String get landingAlreadyHaveAccount => 'Already have an account? Login';

  @override
  String get landingWhyUseApp => 'Why Use Our App?';

  @override
  String get landingLearnRules => 'Learn Rules';

  @override
  String get landingLearnRulesDesc =>
      'Clear explanations of all traffic laws and road signs.';

  @override
  String get landingPracticeExams => 'Practice Exams';

  @override
  String get landingPracticeExamsDesc =>
      'Take mock exams similar to the real driving test.';

  @override
  String get landingTrackProgress => 'Track Progress';

  @override
  String get landingTrackProgressDesc =>
      'Monitor your performance and improve weak areas.';

  @override
  String get landingHowItWorks => 'How It Works';

  @override
  String get landingStep1 => 'Create your free account';

  @override
  String get landingStep2 => 'Start learning traffic rules';

  @override
  String get landingStep3 => 'Take mock exams';

  @override
  String get landingStep4 => 'Pass your real test confidently';

  @override
  String get landingReadyTitle => 'Ready to Pass Your Driving Exam?';

  @override
  String get landingStartLearning => 'Start Learning Now';

  @override
  String get homeServices => 'Services';

  @override
  String get authAppName => 'RWANDA TRAFFIC RULES';

  @override
  String get authSubtitle => 'Official Driving License Learning Platform';

  @override
  String get loginTitle => 'Login to Your Account';

  @override
  String get loginSubtitle => 'Enter your registered phone number to continue.';

  @override
  String get authNeedHelp => 'Need Help?';

  @override
  String get loginHelpText => 'For account issues or inquiries, contact:';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authPhoneHint => '0788 000 000';

  @override
  String get authContinue => 'Continue';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get authSecureTag => 'Secure • Fast • Official Road App';

  @override
  String get loginPhoneRequired => 'Please enter your phone number';

  @override
  String get registerTitle => 'Create Your Account';

  @override
  String get registerSubtitle =>
      'Register using your full name and phone number to begin learning.';

  @override
  String get registerHelpText =>
      'For registration issues or inquiries, contact:';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get registerTerms =>
      'I agree to the Terms of Service and Privacy Policy.';

  @override
  String get registerSignUp => 'Sign Up';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLogIn => 'Log In';

  @override
  String get registerFillAllFields => 'Please fill all fields';

  @override
  String get registerAgreeTerms => 'Please agree to terms and conditions';

  @override
  String get forgotPasswordTitle => 'Password reset is not available';

  @override
  String get forgotPasswordDescription =>
      'This backend uses phone number + device binding (no password reset flow).';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get navHome => 'Home';

  @override
  String get navPractice => 'Practice';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get practiceTitle => 'Practice Quiz';

  @override
  String get practiceCategorySpeedLimits => 'Speed Limits';

  @override
  String get practiceCategoryRoadSigns => 'Road Signs';

  @override
  String get practiceCategoryLaneControl => 'Lane Control';

  @override
  String get practiceCategoryParkingRules => 'Parking Rules';

  @override
  String get practiceStart => 'Start →';

  @override
  String get quizComplete => 'Quiz Complete!';

  @override
  String quizScore(int score) {
    return 'Score: $score%';
  }

  @override
  String quizResult(int correct, int total) {
    return 'You got $correct out of $total correct';
  }

  @override
  String get quizBackToPractice => 'Back to Practice';

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizFinish => 'Finish Quiz';

  @override
  String get quizNextQuestion => 'Next Question';

  @override
  String get examMockExam => 'Mock Exam';

  @override
  String get examInstructions => 'Exam Instructions';

  @override
  String get examTimeLimit => 'Time Limit';

  @override
  String get examTimeLimitDesc => '30 minutes total for 20 questions';

  @override
  String get examQuestionCount => '20 Questions';

  @override
  String get examQuestionCountDesc =>
      'Multiple choice format with 4 options each';

  @override
  String get examPassingScore => 'Passing Score';

  @override
  String get examPassingScoreDesc => 'You need 70% or higher to pass';

  @override
  String get examNoGoingBack => 'No Going Back';

  @override
  String get examNoGoingBackDesc => 'You cannot revisit previous questions';

  @override
  String get examWarning =>
      'Make sure you have stable internet and won\'t be interrupted';

  @override
  String get examStartExam => 'Start Exam';

  @override
  String get examSubmit => 'Submit Exam';

  @override
  String get examCongratulations => 'Congratulations!';

  @override
  String get examGoodEffort => 'Good Effort';

  @override
  String get examPassedMessage => 'You passed the exam with flying colors!';

  @override
  String get examFailedMessage => 'Keep practicing to improve your score';

  @override
  String get examYourScore => 'Your Score';

  @override
  String get examCorrect => 'Correct';

  @override
  String get examAccuracy => 'Accuracy';

  @override
  String get examNeedMorePractice =>
      'You need 70% to pass. Practice more to improve!';

  @override
  String get examBadgeEarned => 'You earned a badge for passing the exam!';

  @override
  String get examRetakeTest => 'Retake Test';

  @override
  String get examBackHome => 'Back Home';

  @override
  String get progressTitle => 'Your Progress';

  @override
  String get progressPerformanceSummary => 'Performance Summary';

  @override
  String get progressTotalAttempts => 'Total Attempts';

  @override
  String get progressBestScore => 'Best Score';

  @override
  String get progressAverageScore => 'Average Score';

  @override
  String get progressSignsLearned => 'Signs Learned';

  @override
  String get progressRecentExams => 'Recent Exams';

  @override
  String get progressOverall => 'Overall Progress';

  @override
  String get progressComplete => 'Complete';

  @override
  String get progressAvgScore => 'Avg Score';

  @override
  String get progressSigns => 'Signs';

  @override
  String get progressPassed => 'Passed';

  @override
  String get progressExcellent => 'Excellent';

  @override
  String progressMockExam(int number) {
    return 'Mock Exam $number';
  }

  @override
  String get progressPracticeQuiz => 'Practice Quiz';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLocation => 'Kigali, Rwanda';

  @override
  String get profileOverallProgress => 'Overall Learning Progress';

  @override
  String profileModulesCompleted(int completed, int total) {
    return '$completed/$total Modules Completed';
  }

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Notifications, language, privacy';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileDeleteConfirmTitle => 'Delete Account';

  @override
  String get profileDeleteConfirmMessage =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get profileDelete => 'Delete';

  @override
  String get certificatesTitle => 'My Certificates';

  @override
  String get certificatesAchievements => 'Your Achievements';

  @override
  String get certificatesEarned => 'Earned';

  @override
  String get certificatesPending => 'Pending';

  @override
  String get certificatesInProgress => 'In Progress';

  @override
  String get certificateRoadSignsMastery => 'Road Signs Mastery';

  @override
  String get certificateTrafficRulesTest => 'Traffic Rules Final Test';

  @override
  String get certificateDefensiveDriving => 'Defensive Driving';

  @override
  String get signsTitle => 'Traffic Signs';

  @override
  String get signsSearchHint => 'Search traffic signs...';

  @override
  String get signsNotFound => 'No traffic signs found';

  @override
  String get signsLearned => 'Learned';

  @override
  String get signsAll => 'All';

  @override
  String get signDetailTitle => 'Traffic Sign';

  @override
  String get signDetailNotFound => 'Sign not found';

  @override
  String get signDetailDescription => 'Description';

  @override
  String get signDetailScenario => 'Real-Life Scenario';

  @override
  String get signDetailLearned => 'You\'ve learned this sign!';

  @override
  String get signDetailMarkAsLearned => 'Mark as Learned';

  @override
  String get signDetailMarkedSuccess => 'Traffic sign marked as learned!';
}
