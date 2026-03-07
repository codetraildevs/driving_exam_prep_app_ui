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

  @override
  String get subscriptionTitle => 'Practice Exam Access';

  @override
  String get subscriptionSubtitle => 'Unlock All Practice Exams';

  @override
  String get subscriptionCurrentPlan => 'Your Current Plan';

  @override
  String get subscriptionNoPlan => 'No active plan';

  @override
  String get subscriptionMonth1 => '1 Month';

  @override
  String get subscriptionMonth3 => '3 Months';

  @override
  String get subscriptionMonth6 => '6 Months';

  @override
  String subscriptionPrice(int amount) {
    return '$amount RWF';
  }

  @override
  String get subscriptionRequestAccess => 'Request Access';

  @override
  String get subscriptionRequestSent =>
      'Your request has been submitted. You will be activated once payment is confirmed.';

  @override
  String get subscriptionPaymentInstructions => 'Payment Instructions';

  @override
  String get subscriptionPaymentMomo => 'MoMo Pay: 323294';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788657595';

  @override
  String get subscriptionHelpCall => 'Call: 0788657595';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788657595';

  @override
  String get subscriptionChoosePlan => 'Choose a Plan';

  @override
  String get subscriptionCurrency => 'Currency: RWF';

  @override
  String get subscriptionAccessActive => 'Access Active';

  @override
  String subscriptionExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String subscriptionDays(int days) {
    return '$days days';
  }

  @override
  String get subscriptionNeedHelp => 'Need Help?';

  @override
  String subscriptionGetAccess(int count) {
    return 'Get access to all $count+ premium practice exams';
  }

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminAccess => 'Access Management';

  @override
  String get adminProgress => 'User Progress';

  @override
  String get adminTotalUsers => 'Total Users';

  @override
  String get adminActiveSubscriptions => 'Active Subscriptions';

  @override
  String get adminUsersByLanguage => 'Users by Language';

  @override
  String get adminRecentRegistrations => 'Recent Registrations';

  @override
  String get adminGrantAccess => 'Grant Access';

  @override
  String get adminCallUser => 'Call User';

  @override
  String get adminCallNotes => 'Call Notes';

  @override
  String get adminLastCalled => 'Last Called';

  @override
  String get adminNoAccess => 'No Access';

  @override
  String get adminHasAccess => 'Has Access';

  @override
  String get adminAccessExpired => 'Access Expired';

  @override
  String adminAccessExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String get adminSearchUsers => 'Search users...';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminFilterHasAccess => 'Has Access';

  @override
  String get adminFilterNoAccess => 'No Access';

  @override
  String get adminManageUsers => 'Manage Users';

  @override
  String get adminManageAccess => 'Manage Access';

  @override
  String get adminViewProgress => 'View Progress';

  @override
  String adminRegistrationDate(String date) {
    return 'Registered: $date';
  }

  @override
  String get adminEnterCallNotes => 'Enter call notes...';

  @override
  String get adminSubmitCall => 'Submit';

  @override
  String get adminCallLogged => 'Call logged successfully';

  @override
  String get adminAccessGranted => 'Access granted successfully';

  @override
  String get adminSelectTier => 'Select Access Tier';

  @override
  String get examListTitle => 'Practice Exams';

  @override
  String get examFree => 'FREE';

  @override
  String get examPaid => 'PAID';

  @override
  String get examLocked => 'Locked';

  @override
  String examQuestions(int count) {
    return '$count questions';
  }

  @override
  String get quizProgress => 'Progress';

  @override
  String quizAnswered(int answered, int total) {
    return 'Answered: $answered/$total';
  }

  @override
  String get quizSubmitPractice => 'Submit Practice';

  @override
  String get quizPrevious => 'Previous';

  @override
  String get quizNext => 'Next';

  @override
  String quizTimeRemaining(String time) {
    return 'Time: $time';
  }

  @override
  String get quizResults => 'Quiz Results';

  @override
  String get quizPassed => 'Passed!';

  @override
  String get quizFailed => 'Keep Practicing';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizSubmitConfirmTitle => 'Submit Quiz?';

  @override
  String quizSubmitConfirmMessage(int answered, int total) {
    return 'You have answered $answered out of $total questions. Are you sure you want to submit?';
  }

  @override
  String get quizTimeUp => 'Time\'s up! Quiz submitted automatically.';

  @override
  String get quizReviewAnswers => 'Review Answers';

  @override
  String get quizRetake => 'Retake Quiz';

  @override
  String get profileRole => 'Role';

  @override
  String get profileLanguage => 'Preferred Language';

  @override
  String profileRegistered(String date) {
    return 'Registered: $date';
  }

  @override
  String get profileAccessStatus => 'Access Status';

  @override
  String get profileExamHistory => 'Exam History';

  @override
  String get profileCallHistory => 'Call History';

  @override
  String get paymentInstructionsTitle => 'Payment Instructions';

  @override
  String get paymentMomoPayNumber => 'MoMo Pay: 323294';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788657595';

  @override
  String get paymentHelpText => 'Need help? Call or WhatsApp: 0788657595';

  @override
  String get commonError => 'Something went wrong. Please try again.';

  @override
  String get adminTierLabel => 'Tier';

  @override
  String get adminExpiresLabel => 'Expires';

  @override
  String get adminRenewAccess => 'Renew / Extend Access';

  @override
  String get adminManagePlatform => 'Manage Platform';

  @override
  String get adminManageExams => 'Manage Exams';

  @override
  String get adminManageExamsDesc => 'View and manage all practice exams';

  @override
  String get adminManageUsersDesc => 'View, search, and manage all users';

  @override
  String get adminAccessCodesDesc => 'Manage access codes and payments';

  @override
  String get adminQuickStats => 'Quick Stats';

  @override
  String get adminActionsTitle => 'Admin Actions';

  @override
  String get adminTotalPractices => 'Total Practices';

  @override
  String get adminManagePlatformDesc => 'Manage your traffic rules learning platform';

  @override
  String get adminNotifications => 'Notifications';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceDesc => 'Choose how the app looks';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';
}
