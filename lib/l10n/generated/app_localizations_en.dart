// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rwanda Traffic Rule';

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
  String get homeMockExams => 'Practice Exams';

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
  String get settingsAboutApp => 'About Rwanda Traffic Rule';

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
  String get authAppName => 'Rwanda Traffic Rule';

  @override
  String get authSubtitle => 'Prepare for Your Provisional Driving Licence';

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
  String get authPhoneHint => '07** *** ***';

  @override
  String get authContinue => 'Continue';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get authSecureTag => 'Secure • Fast • Pass';

  @override
  String get loginPhoneRequired => 'Please enter your phone number';

  @override
  String get loginInvalidPhone =>
      'Enter a valid phone number (e.g. 078... or +250 78...)';

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
  String get practiceTitle => 'Practice ';

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
  String get examMockExam => 'Practice Exam';

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
  String get progressPracticeQuiz => 'Practice Exams';

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
  String get subscriptionTrafficRulesMsg =>
      'If you want to learn traffic rules, kindly call, text us on WhatsApp and help to be prepared for official provisional driving license.';

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
  String get subscriptionPaymentMomo => 'MoMo Pay: 329494';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788659575';

  @override
  String get subscriptionPaymentTigoCash => 'Tigo Cash: 0728877442';

  @override
  String get subscriptionHelpCall => 'Call: 0788659575';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788659575';

  @override
  String get subscriptionChoosePlan => 'Choose a Plan to';

  @override
  String get subscriptionCurrency => 'Months to learn';

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
  String get adminCustomDays => 'Custom Duration (days)';

  @override
  String get adminPaymentAmount => 'Amount (RWF)';

  @override
  String get adminEnterDays => 'Enter number of days';

  @override
  String get adminEnterAmount => 'Enter amount in RWF';

  @override
  String get adminOrCustom => 'Or set custom days';

  @override
  String get adminPendingRequests => 'Pending Payment Requests';

  @override
  String get adminAllUsersList => 'All Users';

  @override
  String get adminInvalidAmount => 'Please enter a valid amount greater than 0';

  @override
  String get adminInvalidDays =>
      'Please enter a valid number of days greater than 0';

  @override
  String get adminAccessRevoked => 'Access revoked';

  @override
  String get adminNoUsers => 'No users found';

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
  String get quizSubmitPractice => 'Submit exam';

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
  String get paymentMomoPayNumber => 'MoMo Pay: 329494';

  @override
  String get paymentMomoPayDial =>
      'To pay with MoMo Pay, dial: *182*8*1*329494*amount#';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788659575';

  @override
  String get paymentTigoCashNumber => 'Tigo Cash: 0728877442';

  @override
  String get paymentMobileMoneyDial =>
      'To pay with Mobile Money, dial: *182*1*1*0788659575*amount#';

  @override
  String get paymentTigoCashDial =>
      'To pay with Tigo Cash, dial *182*1*1*0728877442*amount#';

  @override
  String get paymentHelpText => 'Need help? Call or WhatsApp: 0788659575';

  @override
  String get paymentHelpContact =>
      'You can copy or call: 0788659575 or WhatsApp: 0788659575 for help.';

  @override
  String get paymentError =>
      'Payment request failed. Please pay manually using the instructions below.';

  @override
  String get paymentCopyNumber => 'Copy Number';

  @override
  String get paymentCallNumber => 'Call 0788659575';

  @override
  String get paymentCallTigoNumber => 'Call 0728877442';

  @override
  String get paymentWhatsApp => 'Send Message on WhatsApp';

  @override
  String get paymentWhatsAppMessage => 'Request access for driving exam app';

  @override
  String get paymentRequestExists =>
      'A payment request for this plan is already pending. Please wait for activation or contact support.';

  @override
  String get commonError => 'Something went wrong. Please try again.';

  @override
  String get commonRetry => 'Retry';

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
  String get adminManagePlatformDesc =>
      'Manage your traffic rules learning platform';

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

  @override
  String get examWrong => 'Wrong';

  @override
  String get examTimeSpent => 'Time';

  @override
  String get profileLogoutConfirmTitle => 'Sign Out?';

  @override
  String get profileLogoutConfirmMessage =>
      'Are you sure you want to sign out of your account?';

  @override
  String get profileDeleteInstructions =>
      'Before deleting your account:\n• All your exam results will be permanently erased\n• Your access subscription will be removed\n• This action cannot be undone\n• You will need to re-register to use the app again';

  @override
  String get progressExamsTaken => 'Exams Taken';

  @override
  String get progressPassedCount => 'Passed';

  @override
  String get progressFailedCount => 'Failed';

  @override
  String get progressPassRate => 'Pass Rate';

  @override
  String get progressNoExams => 'No exams taken yet. Start practicing!';

  @override
  String get certificateReadyTitle => 'Ready for Official Exam!';

  @override
  String certificateReadySubtitle(int count) {
    return 'You have passed $count exams. You are ready for the official driving license test.';
  }

  @override
  String get certificateIremboLink =>
      'Register for Official Exam on irembo.gov.rw';

  @override
  String get certificateIremboDesc =>
      'Click below to register for the official provisional driving license computer-based test';

  @override
  String certificateExamsNeeded(int needed) {
    return 'Pass $needed more exams to earn your certificate';
  }

  @override
  String certificateProgressLabel(int passed, int total) {
    return '$passed of $total required exams passed';
  }

  @override
  String get adminSortAsc => 'Oldest First';

  @override
  String get adminSortDesc => 'Newest First';

  @override
  String get adminFilterToday => 'Today';

  @override
  String get adminDateRange => 'Date Range';

  @override
  String get adminFilterRole => 'Role';

  @override
  String get adminBlockUser => 'Block User';

  @override
  String get adminUnblockUser => 'Unblock User';

  @override
  String get adminDeleteUserAction => 'Delete User';

  @override
  String adminBlockUserConfirm(String name) {
    return 'Block $name? They will lose access and cannot log in.';
  }

  @override
  String adminDeleteUserConfirm(String name) {
    return 'Permanently delete $name? All their data will be erased. This cannot be undone.';
  }

  @override
  String get adminUserBlocked => 'User blocked successfully';

  @override
  String get adminUserUnblocked => 'User unblocked successfully';

  @override
  String get adminUserDeleted => 'User deleted successfully';

  @override
  String get adminMustBlockFirst =>
      'You must block the user before deleting them.';

  @override
  String get adminBlockAccess => 'Block Access';

  @override
  String get adminDeleteAccess => 'Delete Access';

  @override
  String get adminBlockAccessConfirm =>
      'Block this access code? The user will lose access immediately.';

  @override
  String get adminDeleteAccessConfirm => 'Delete this access code permanently?';

  @override
  String get adminAccessBlocked => 'Access code blocked';

  @override
  String get adminAccessDeleted => 'Access code deleted';

  @override
  String adminPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get adminLearningLanguage => 'Learning';

  @override
  String get adminIsBlocked => 'Blocked';

  @override
  String get adminIsActive => 'Active';

  @override
  String get generalCopied => 'Copied!';

  @override
  String get adminRetry => 'Retry';

  @override
  String get languageSelectDescription =>
      'You can change this later in Settings — get localized traffic alerts and routing.';

  @override
  String get languageSelectDeviceLanguage => 'Use device language';

  @override
  String get languageSelectHelpTooltip => 'Language help';

  @override
  String get languageSelectMaybeLater => 'Maybe later';

  @override
  String get languageSelectHelpTitle => 'Why choose a language?';

  @override
  String get languageSelectHelpContent =>
      'Selecting a language ensures that alerts, maps, and voice prompts are shown in your preferred language. You can change this later in Settings.';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get languageSelectDialogTitle => 'Select language';

  @override
  String get examNotFound => 'Exam not found';

  @override
  String errorWithDetail(String detail) {
    return 'Error: $detail';
  }

  @override
  String errorUnexpected(String detail) {
    return 'Unexpected error: $detail';
  }

  @override
  String priceRwf(String amount) {
    return '$amount RWF';
  }

  @override
  String errorHttpStatus(int code) {
    return 'HTTP $code';
  }

  @override
  String get examSampleQ1 => 'What is the speed limit on highways?';

  @override
  String get examSampleQ1A1 => '90 km/h';

  @override
  String get examSampleQ1A2 => '100 km/h';

  @override
  String get examSampleQ1A3 => '110 km/h';

  @override
  String get examSampleQ1A4 => '120 km/h';

  @override
  String get examSampleQ2 => 'What does a yellow traffic light mean?';

  @override
  String get examSampleQ2A1 => 'Stop immediately';

  @override
  String get examSampleQ2A2 => 'Go ahead';

  @override
  String get examSampleQ2A3 => 'Be prepared to stop';

  @override
  String get examSampleQ2A4 => 'Turn around';

  @override
  String get examSampleQ3 => 'How far from a fire hydrant can you park?';

  @override
  String get examSampleQ3A1 => '1 meter';

  @override
  String get examSampleQ3A2 => '3 meters';

  @override
  String get examSampleQ3A3 => '5 meters';

  @override
  String get examSampleQ3A4 => '10 meters';

  @override
  String get examShareResult => 'Share Result';

  @override
  String get examCopiedToClipboard => 'Result copied to clipboard';

  @override
  String get examGradeLabel => 'Grade';

  @override
  String get subscriptionPopular => '★ Popular';

  @override
  String get quizTimeTaken => 'Time Taken';

  @override
  String get progressTotalQuestions => 'Total Questions';

  @override
  String get progressCorrectAnswers => 'Correct';

  @override
  String get progressIncorrect => 'Incorrect';

  @override
  String get errorNetwork =>
      'Unable to connect. Please check your internet connection and try again.';

  @override
  String get paymentChooseMethod => 'Choose Payment Method';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'Rwanda Traffic Rule';

  @override
  String get aboutDescription =>
      'Rwanda Traffic Rule is your companion for learning Rwanda traffic rules, road signs, and practicing theory questions to prepare for the provisional driving licence test. This is an independent educational app and is not affiliated with any government authority.';

  @override
  String get aboutFeatures => 'Key Features';

  @override
  String get aboutFeaturePractice => 'Practice Exams';

  @override
  String get aboutFeatureProgress => 'Track Progress';

  @override
  String get aboutFeatureMultilingual => '3 Languages';

  @override
  String get aboutFeatureCertificate => 'Certificates';

  @override
  String get aboutContact => 'Contact Us';

  @override
  String get aboutContactInfo =>
      'Phone/WhatsApp: 0788659575 / 0728877442\nEmail: info@Rwanda Traffic Rule.rw';

  @override
  String get aboutCopyright => 'Copyright';

  @override
  String get aboutCopyrightText =>
      '© 2026 Rwanda Traffic Rule. All rights reserved.';

  @override
  String get privacyLastUpdated => 'Last updated: March 2026';

  @override
  String get privacyIntro =>
      'Rwanda Traffic Rule is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your personal information when you use our educational application. We are an independent educational service and are not affiliated with any government authority.';

  @override
  String get privacyDataCollection => 'Data Collection';

  @override
  String get privacyDataCollectionBody =>
      'We collect your phone number and full name when you register. We also collect your practice quiz results and progress data to provide personalized learning insights. A unique device identifier is generated to secure your account.';

  @override
  String get privacyDataUsage => 'How We Use Your Data';

  @override
  String get privacyDataUsageBody =>
      'Your data is used to provide and improve our services, track your learning progress, manage your subscription, and communicate important updates about the application.';

  @override
  String get privacyDataProtection => 'Data Protection';

  @override
  String get privacyDataProtectionBody =>
      'We use industry-standard security measures including encrypted data transmission and secure server storage. Your personal data is never shared with third parties without your consent.';

  @override
  String get privacyDataSharing => 'Data Sharing';

  @override
  String get privacyDataSharingBody =>
      'We do not sell, trade, or rent your personal data. We may share anonymous aggregated data for statistical purposes only.';

  @override
  String get privacyUserRights => 'Your Rights';

  @override
  String get privacyUserRightsBody =>
      'You have the right to access, update, or delete your personal data at any time. You can request data deletion by contacting our support team or using the Delete Account option in Settings.';

  @override
  String get termsLastUpdated => 'Last updated: March 2026';

  @override
  String get termsIntro =>
      'By using Rwanda Traffic Rule, you agree to the following terms and conditions. Please read them carefully before using the application. Rwanda Traffic Rule is an independent educational app designed to help you prepare for the driving theory test. We are not affiliated with any government body or the official exam provider.';

  @override
  String get termsAcceptance => 'Acceptance of Terms';

  @override
  String get termsAcceptanceBody =>
      'By creating an account and using this application, you agree to be bound by these terms. If you do not agree, please discontinue use immediately.';

  @override
  String get termsUserAccount => 'User Account';

  @override
  String get termsUserAccountBody =>
      'You are responsible for maintaining the security of your account. Each account is linked to a single phone number and device. Sharing account credentials is not permitted.';

  @override
  String get termsContent => 'Content & Exams';

  @override
  String get termsContentBody =>
      'All content is for educational and practice purposes only. It does not represent the official government exam. We strive for accuracy but make no guarantees about exam outcomes based on practice results. Rwanda Traffic Rule is not affiliated with any government authority.';

  @override
  String get termsPayment => 'Requesting to unlock exams';

  @override
  String get termsPaymentBody =>
      'To unlock exams, please contact us at 0788659575 or 0728877442.';

  @override
  String get termsTermination => 'Account Termination';

  @override
  String get termsTerminationBody =>
      'We reserve the right to suspend or terminate accounts that violate these terms, engage in fraudulent activity, or misuse the platform. You may delete your account at any time from settings.';

  @override
  String get aboutDisclaimer => 'Disclaimer';

  @override
  String get aboutDisclaimerText =>
      'Rwanda Traffic Rule is an independent educational app designed to help users learn traffic rules and prepare for the driving theory test. This app is not affiliated with, endorsed by, or connected to any government authority or official exam body. All content is for practice and learning purposes only.';

  @override
  String get profileCertificatesTitle => 'Certificates';

  @override
  String get profileCertificatesSubtitle =>
      'Certificates earned and progress towards next one';

  @override
  String get offlineBanner =>
      'You are offline. Data shown may not be up to date.';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get dataSynced => 'Data synced successfully';

  @override
  String get savedOffline => 'Saved offline. Will sync when connected.';

  @override
  String certificateUniqueExamsPassed(int count, int total) {
    return '$count of $total unique exams passed';
  }

  @override
  String certificatePassMark(int required, int total, int percent) {
    return 'Pass mark: $required/$total ($percent%)';
  }

  @override
  String get certificateLatestAttempt => 'Latest attempt';

  @override
  String certificateExamStatus(int index) {
    return 'Exam $index';
  }

  @override
  String get certificateNotAttempted => 'Not attempted';

  @override
  String get consentTitle => 'Your Privacy Matters';

  @override
  String get consentBody =>
      'Rwanda Traffic Rule collects and processes the following data to provide you with the best learning experience:\n\n• Phone number & name — for account creation and authentication\n• Device identifier — a hashed fingerprint to secure your account\n• Exam results & progress — to track your learning journey\n• Offline cache — so the app works without internet\n\nYour data is stored securely and is never sold to third parties. You can delete your account and all associated data at any time from your profile.';

  @override
  String get consentAccept => 'I understand and agree';

  @override
  String get consentReadPolicy => 'Read Privacy Policy';

  @override
  String get registerInvalidName => 'Name must contain only letters and spaces';

  @override
  String get registerInvalidPhone =>
      'Enter a valid phone number (e.g. 078... or +250 78...)';

  @override
  String get joinGroup => 'WhatsApp Group';

  @override
  String get joinGroupSubtitle => 'Join a WhatsApp group';

  @override
  String get adminOfflineTooltip => 'Offline – showing cached data';

  @override
  String get adminOfflineBadge => 'OFFLINE';

  @override
  String adminActiveLabel(int count) {
    return '$count active';
  }

  @override
  String get adminFallbackName => 'Admin';

  @override
  String get adminNoNetworkError => 'No network. No cached data available.';

  @override
  String get commonErrorTitle => 'Error';

  @override
  String get exitAppTitle => 'Exit App';

  @override
  String get exitAppMessage => 'Are you sure you want to exit the app?';

  @override
  String get exitAppYes => 'Exit';

  @override
  String get exitAppNo => 'Stay';

  @override
  String get consentItemPhone => 'Phone number & name';

  @override
  String get consentItemPhoneDetail => 'Account creation & authentication';

  @override
  String get consentItemDevice => 'Device identifier';

  @override
  String get consentItemDeviceDetail =>
      'Hashed fingerprint to secure your account';

  @override
  String get consentItemProgress => 'Exam results & progress';

  @override
  String get consentItemProgressDetail => 'Track your learning journey';

  @override
  String get consentItemCache => 'Offline cache';

  @override
  String get consentItemCacheDetail => 'App works without internet';

  @override
  String get consentSecurityNote =>
      'Your data is stored securely and never sold to third parties.';
}
