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
  String homeGreeting(Object userName) {
    return '$userName';
  }

  @override
  String get homeContinueMessage => 'Continue mastering traffic rules today.';

  @override
  String get homeContinueLearning => 'Continue Learning';

  @override
  String homeAccessActive(Object daysLeft) {
    return 'Access Active - $daysLeft days left';
  }

  @override
  String homePaymentTier(Object tier) {
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
  String get homeShareAppMessage =>
      'Download Rwanda Traffic Rule to learn traffic rules and pass your exam!';

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
  String settingsVersion(Object version) {
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
  String get settingsResetProgressSubtitle => 'Delete all your data';

  @override
  String get settingsResetConfirmTitle => 'Reset Progress';

  @override
  String get settingsResetConfirmMessage =>
      'Are you sure you want to reset all your progress? This action cannot be undone.';

  @override
  String get settingsResetSuccess => 'Progress reset successfully';

  @override
  String get settingsSelectLanguage => 'Choose language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonMenu => 'Menu';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonReset => 'Reset';

  @override
  String get landingHeroTitle => 'Learn traffic rules easily';

  @override
  String get landingHeroSubtitle =>
      'Practice on your own questions and pass your exam.';

  @override
  String get landingGetStarted => 'Get Started';

  @override
  String get landingAlreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get landingWhyUseApp => 'Why use our app?';

  @override
  String get landingLearnRules => 'Learn rules';

  @override
  String get landingLearnRulesDesc =>
      'Clear explanations of all traffic rules and signs.';

  @override
  String get landingPracticeExams => 'Practice exams';

  @override
  String get landingPracticeExamsDesc =>
      'Take practice exams similar to the real exam.';

  @override
  String get landingTrackProgress => 'Track progress';

  @override
  String get landingTrackProgressDesc =>
      'Track your performance and see where you want to go.';

  @override
  String get landingHowItWorks => 'How it works';

  @override
  String get landingStep1 => 'Open your free account';

  @override
  String get landingStep2 => 'Start learning traffic rules';

  @override
  String get landingStep3 => 'Take practice exams';

  @override
  String get landingStep4 => 'Pass the real exam with confidence';

  @override
  String get landingReadyTitle =>
      'Ready to pass your health driving license exam?';

  @override
  String get landingStartLearning => 'Start learning now';

  @override
  String get homeServices => 'Services';

  @override
  String get authAppName => 'Rwanda Traffic Rule';

  @override
  String get authSubtitle =>
      'Prepare for your provisional license driving theory exam';

  @override
  String get loginTitle => 'Sign in to your account';

  @override
  String get loginSubtitle =>
      'Enter your phone number (used during registration) to continue.';

  @override
  String get authNeedHelp => 'Need help?';

  @override
  String get loginHelpText => 'For account issues, contact:';

  @override
  String get authPhoneNumber => 'Enter your phone number';

  @override
  String get authPhoneHint => '07** *** ***';

  @override
  String get authContinue => 'Continue';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginSignUp => 'Sign up';

  @override
  String get authSecureTag => 'Learn • Prepare • Pass';

  @override
  String get loginPhoneRequired => 'Please enter your phone number';

  @override
  String get loginInvalidPhone =>
      'Enter a valid phone number (e.g., 07... or +250 7...)';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle =>
      'Sign up using your full name and phone number to start learning.';

  @override
  String get registerHelpText =>
      'For sign-up issues or other questions, contact:';

  @override
  String get authFullName => 'Enter your name';

  @override
  String get authFullNameHint => 'Enter your name';

  @override
  String get registerTerms => 'Accept the usage and privacy policies.';

  @override
  String get registerSignUp => 'Confirm';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLogIn => 'Sign in';

  @override
  String get registerFillAllFields => 'Please fill all fields';

  @override
  String get registerAgreeTerms => 'Please accept required terms';

  @override
  String get forgotPasswordTitle => 'Reset password not possible';

  @override
  String get forgotPasswordDescription =>
      'The system uses phone number and device link (no password reset).';

  @override
  String get forgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get navHome => 'Home';

  @override
  String get navPractice => 'Practice';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get practiceTitle => 'Practice Exams';

  @override
  String get practiceCategorySpeedLimits => 'Speed limits';

  @override
  String get practiceCategoryRoadSigns => 'Traffic signs';

  @override
  String get practiceCategoryLaneControl => 'Lane guidance';

  @override
  String get practiceCategoryParkingRules => 'Parking rules';

  @override
  String get practiceStart => 'Start →';

  @override
  String get quizComplete => 'Exam complete!';

  @override
  String quizScore(Object score) {
    return 'Score: $score%';
  }

  @override
  String quizResult(Object correct, Object total) {
    return 'You answered $correct out of $total correctly';
  }

  @override
  String get quizBackToPractice => 'Try another exam';

  @override
  String get quizNextQuestion => 'Next question';

  @override
  String get examMockExam => 'Practice Exams';

  @override
  String get examInstructions => 'Exam instructions';

  @override
  String get examTimeLimit => 'Time limit';

  @override
  String get examTimeLimitDesc => '30 minutes total with 20 questions';

  @override
  String get examQuestionCount => '20 questions';

  @override
  String get examQuestionCountDesc => 'Multiple choice with 4 options each';

  @override
  String get examPassingScore => 'Passing score';

  @override
  String get examPassingScoreDesc => 'You need 70% or above to pass';

  @override
  String get examNoGoingBack => 'No going back';

  @override
  String get examNoGoingBackDesc => 'You cannot go back to previous questions';

  @override
  String get examWarning =>
      'Make sure you have a stable internet connection and won\'t be interrupted';

  @override
  String get examStartExam => 'Start Exam';

  @override
  String get examSubmit => 'Submit Exam';

  @override
  String get examCongratulations => 'Congratulations!';

  @override
  String get examGoodEffort => 'Good effort';

  @override
  String get examPassedMessage => 'You passed the exam with flying colors!';

  @override
  String get examFailedMessage => 'Keep practicing to improve your score';

  @override
  String get examYourScore => 'Your score';

  @override
  String get examCorrect => 'Correct answers';

  @override
  String get examAccuracy => 'Accuracy';

  @override
  String get examNeedMorePractice => 'You need 70% to pass. Keep practicing!';

  @override
  String get examBadgeEarned => 'You earned a badge for passing the exam!';

  @override
  String get examRetakeTest => 'Retake Exam';

  @override
  String get examBackHome => 'Back to Home';

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
  String get progressAvgScore => 'Avg. score';

  @override
  String get progressSigns => 'Signs';

  @override
  String get progressPassed => 'Passed';

  @override
  String get progressExcellent => 'Excellent';

  @override
  String progressMockExam(Object number) {
    return 'Practice Exam $number';
  }

  @override
  String get progressPracticeQuiz => 'Practice Quiz';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLocation => 'Kigali, Rwanda';

  @override
  String get profileOverallProgress => 'Overall Progress';

  @override
  String profileModulesCompleted(Object completed, Object total) {
    return '$completed/$total exams completed';
  }

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Notifications, language, data';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteConfirmTitle => 'Delete account';

  @override
  String get profileDeleteConfirmMessage =>
      'Are you sure you want to delete your account entirely? This action cannot be undone.';

  @override
  String get profileDelete => 'Delete';

  @override
  String get certificatesTitle => 'My Certificates';

  @override
  String get certificatesAchievements => 'Achievements';

  @override
  String get certificatesEarned => 'Earned';

  @override
  String get certificatesPending => 'Pending';

  @override
  String get certificatesInProgress => 'In Progress';

  @override
  String get certificateRoadSignsMastery => 'Traffic sign mastery';

  @override
  String get certificateTrafficRulesTest => 'Traffic rules test';

  @override
  String get certificateDefensiveDriving => 'Defensive driving';

  @override
  String get signsTitle => 'Traffic Signs';

  @override
  String get signsSearchHint => 'Search for traffic signs...';

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
  String get signDetailScenario => 'Real-life scenario';

  @override
  String get signDetailLearned => 'You learned this sign!';

  @override
  String get signDetailMarkAsLearned => 'Mark as learned';

  @override
  String get signDetailMarkedSuccess => 'Sign marked as learned!';

  @override
  String get subscriptionTitle => 'Request exam access';

  @override
  String get subscriptionSubtitle => 'request exam access';

  @override
  String get subscriptionTrafficRulesMsg =>
      'If you want to learn traffic rules, contact us or send us a WhatsApp message and we will help you prepare well for your provisional license driving theory exam.';

  @override
  String get subscriptionCurrentPlan => 'Your current plan';

  @override
  String get subscriptionNoPlan => 'No active plan';

  @override
  String get subscriptionMonth1 => '1 Month';

  @override
  String get subscriptionMonth3 => '3 Months';

  @override
  String get subscriptionMonth6 => '6 Months';

  @override
  String subscriptionPrice(Object amount) {
    return '$amount RWF';
  }

  @override
  String get subscriptionRequestAccess => 'Request Access';

  @override
  String get subscriptionRequestSent =>
      'Your request has been sent successfully.Wait a moment for them to see that you have been approved.';

  @override
  String get subscriptionPaymentInstructions => 'Payment instructions';

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
  String get subscriptionChoosePlan => 'Choose a learning plan';

  @override
  String get subscriptionCurrency => 'Months you want to learn';

  @override
  String get subscriptionAccessActive => 'Access available';

  @override
  String subscriptionExpires(Object date) {
    return 'Expires: $date';
  }

  @override
  String subscriptionDays(Object days) {
    return '$days days';
  }

  @override
  String get subscriptionNeedHelp => 'Need help?';

  @override
  String subscriptionGetAccess(Object count) {
    return 'Get $count+ exam practice access';
  }

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminAccess => 'Manage Access';

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
  String adminAccessExpires(Object date) {
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
  String adminRegistrationDate(Object date) {
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
  String get adminSelectTier => 'Select Access Level';

  @override
  String get adminCustomDays => 'Custom Days';

  @override
  String get adminPaymentAmount => 'Payment Amount (RWF)';

  @override
  String get adminEnterDays => 'Enter number of days';

  @override
  String get adminEnterAmount => 'Enter amount in RWF';

  @override
  String get adminOrCustom => 'Or enter custom days';

  @override
  String get adminPendingRequests => 'Pending payment requests';

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
  String get examLocked => 'locked';

  @override
  String examQuestions(Object count) {
    return '$count questions';
  }

  @override
  String get quizProgress => 'Progress';

  @override
  String quizAnswered(Object answered, Object total) {
    return 'Answered: $answered/$total';
  }

  @override
  String get quizSubmitPractice => 'Submit Exam';

  @override
  String get quizPrevious => 'previous';

  @override
  String get quizNext => 'next';

  @override
  String quizTimeRemaining(Object time) {
    return 'Time: $time';
  }

  @override
  String get quizResults => 'Exam Results';

  @override
  String get quizPassed => 'Passed!';

  @override
  String get quizFailed => 'Failed';

  @override
  String quizQuestionOf(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get quizSubmitConfirmTitle => 'Submit Exam?';

  @override
  String quizSubmitConfirmMessage(Object answered, Object total) {
    return 'You have answered $answered out of $total questions. Are you sure you want to submit?';
  }

  @override
  String get quizTimeUp =>
      'Time\'s up! The practice exam has been submitted automatically.';

  @override
  String get quizReviewAnswers => 'Review Answers';

  @override
  String get quizRetake => 'Retake Exam';

  @override
  String get profileRole => 'Role';

  @override
  String get profileLanguage => 'Preferred Language';

  @override
  String profileRegistered(Object date) {
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
      'To pay with Tigo Cash, dial: *182*1*1*0728877442*amount#';

  @override
  String get paymentHelpText => 'Need help? Call or WhatsApp: 0788659575';

  @override
  String get paymentHelpContact =>
      'You can copy or call: 0788659575 or WhatsApp: 0788659575 for help.';

  @override
  String get paymentError =>
      'Payment request conflict. Please pay using the instructions provided here.';

  @override
  String get paymentCopyNumber => 'Copy number';

  @override
  String get paymentCallNumber => 'Call 0788659575';

  @override
  String get paymentCallTigoNumber => 'Call 0728877442';

  @override
  String get paymentWhatsApp => 'Send message to WhatsApp';

  @override
  String get paymentWhatsAppMessage =>
      'Request access to use the driving theory exam app';

  @override
  String get paymentRequestExists =>
      'Payment request already sent. Wait a moment for them to help you or contact help numbers and send a WhatsApp message which will appear below the page';

  @override
  String get commonError => 'Something went wrong. Please try again.';

  @override
  String get commonRetry => 'Try again';

  @override
  String get adminTierLabel => 'Level';

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
  String get adminManageUsersDesc => 'View, search and manage all users';

  @override
  String get adminAccessCodesDesc => 'Manage access codes and payment';

  @override
  String get adminQuickStats => 'Quick Stats';

  @override
  String get adminActionsTitle => 'Admin Actions';

  @override
  String get adminTotalPractices => 'Total Practices';

  @override
  String get adminManagePlatformDesc => 'Manage the traffic rules platform';

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
  String get profileLogoutConfirmTitle => 'Sign out?';

  @override
  String get profileLogoutConfirmMessage =>
      'Do you want to sign out of your account?';

  @override
  String get profileDeleteInstructions =>
      'Before deleting your account:\n• All your answers will be deleted\n• Your subscription will be deleted\n• You will need to sign up again to use the app';

  @override
  String get progressExamsTaken => 'Exams Taken';

  @override
  String get progressPassedCount => 'Exams Passed';

  @override
  String get progressFailedCount => 'Exams Failed';

  @override
  String get progressPassRate => 'Pass Rate';

  @override
  String get progressNoExams => 'No exams taken. Start taking exams!';

  @override
  String get certificateReadyTitle => 'Ready for the real exam!';

  @override
  String certificateReadySubtitle(Object count) {
    return 'You have completed $count exams. You are ready for the driving license access exam.';
  }

  @override
  String get certificateIremboLink =>
      'Apply for the government exam at irembo.gov.rw';

  @override
  String get certificateIremboDesc =>
      'Click here to apply for the online government driving license theory exam';

  @override
  String certificateExamsNeeded(Object needed) {
    return 'Pass $needed more exams to get the certificate proving you are ready for the provisional license driving theory exam';
  }

  @override
  String certificateProgressLabel(Object passed, Object total) {
    return '$passed of $total required exams';
  }

  @override
  String get adminSortAsc => 'Oldest first';

  @override
  String get adminSortDesc => 'Newest first';

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
  String adminBlockUserConfirm(Object name) {
    return 'Are you sure you want to block $name? They will no longer be able to sign in.';
  }

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'Delete $name entirely? All their data will be deleted.';
  }

  @override
  String get adminUserBlocked => 'User blocked successfully';

  @override
  String get adminUserUnblocked => 'User unblocked successfully';

  @override
  String get adminUserDeleted => 'User deleted successfully';

  @override
  String get adminMustBlockFirst =>
      'You must block the user first before deleting them.';

  @override
  String get adminBlockAccess => 'Block Access';

  @override
  String get adminDeleteAccess => 'Delete Access';

  @override
  String get adminBlockAccessConfirm =>
      'Block access code? The user will no longer be able to use the app.';

  @override
  String get adminDeleteAccessConfirm => 'Delete this access code?';

  @override
  String get adminAccessBlocked => 'Access code blocked';

  @override
  String get adminAccessDeleted => 'Access code deleted';

  @override
  String adminPage(Object page, Object total) {
    return 'Page $page of $total';
  }

  @override
  String get adminLearningLanguage => 'Language of Interest';

  @override
  String get adminIsBlocked => 'Blocked';

  @override
  String get adminIsActive => 'Active';

  @override
  String get generalCopied => 'Copied!';

  @override
  String get adminRetry => 'Try again';

  @override
  String get languageSelectDescription =>
      'You can change the language later in Settings.';

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
      'Choosing a language makes text, icons, and voice prompts appear in your language. You can change the language later in Settings.';

  @override
  String get commonGotIt => 'Got it';

  @override
  String get languageSelectDialogTitle => 'Choose Language';

  @override
  String get examNotFound => 'Exam not found';

  @override
  String errorWithDetail(Object detail) {
    return 'Error: $detail';
  }

  @override
  String errorUnexpected(Object detail) {
    return 'Unexpected error: $detail';
  }

  @override
  String priceRwf(Object amount) {
    return '$amount RWF';
  }

  @override
  String errorHttpStatus(Object code) {
    return 'HTTP $code';
  }

  @override
  String get examSampleQ1 => 'What is the maximum speed on a major road?';

  @override
  String get examSampleQ1A1 => '90 km/h';

  @override
  String get examSampleQ1A2 => '100 km/h';

  @override
  String get examSampleQ1A3 => '110 km/h';

  @override
  String get examSampleQ1A4 => '120 km/h';

  @override
  String get examSampleQ2 => 'What does this traffic sign mean?';

  @override
  String get examSampleQ2A1 => 'Stop right there';

  @override
  String get examSampleQ2A2 => 'Continue';

  @override
  String get examSampleQ2A3 => 'Prepare to stop';

  @override
  String get examSampleQ2A4 => 'Change lane';

  @override
  String get examSampleQ3 => 'How far can you park from a water fire hydrant?';

  @override
  String get examSampleQ3A1 => '1 meter';

  @override
  String get examSampleQ3A2 => '3 meters';

  @override
  String get examSampleQ3A3 => '5 meters';

  @override
  String get examSampleQ3A4 => '10 meters';

  @override
  String get examShareResult => 'Share Results';

  @override
  String get examCopiedToClipboard => 'Results copied';

  @override
  String get examGradeLabel => 'Score';

  @override
  String get subscriptionPopular => '★ Popular';

  @override
  String get quizTimeTaken => 'Time Used';

  @override
  String get progressTotalQuestions => 'Questions';

  @override
  String get progressCorrectAnswers => 'Questions Correct';

  @override
  String get progressIncorrect => 'Questions Wrong';

  @override
  String get errorNetwork =>
      'Cannot connect. Check your internet and try again.';

  @override
  String get paymentChooseMethod => 'Choose payment method';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutAppName => 'Rwanda Traffic Rule';

  @override
  String get aboutDescription =>
      'Rwanda Traffic Rule is your helper for learning traffic rules, traffic signs, and practicing exam questions to prepare for your provisional license driving theory exam. This is an independent educational app and is not affiliated with any government or testing center.';

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
  String get aboutContactInfo => 'Tel/WhatsApp: 0788659575 / 0728877442';

  @override
  String get aboutCopyright => 'App owner rights';

  @override
  String get aboutCopyrightText =>
      '© 2026 Rwanda Traffic Rule. App owner rights reserved.';

  @override
  String get privacyLastUpdated => 'Last updated: February 2026';

  @override
  String get privacyIntro =>
      'Rwanda Traffic Rule cares about your privacy. These guidelines explain how we collect, use, and protect your data. We are an independent educational service and are not affiliated with any government agency.';

  @override
  String get privacyDataCollection => 'Data Collection';

  @override
  String get privacyDataCollectionBody =>
      'We collect your phone number and full name when you sign up. We also collect your device fingerprint, which is a unique identifier used to protect your account. We collect your exam answers and progress data. A unique device ID is created to secure your account.';

  @override
  String get privacyDataUsage => 'How We Use Your Data';

  @override
  String get privacyDataUsageBody =>
      'Your data is used to provide and improve our services, track your progress, manage your subscriptions, and send you important information.';

  @override
  String get privacyDataProtection => 'Data Protection';

  @override
  String get privacyDataProtectionBody =>
      'We use high-level security measures, including encrypted transmission and secure storage. Your personal data is never shared without your consent.';

  @override
  String get privacyDataSharing => 'Data Sharing';

  @override
  String get privacyDataSharingBody =>
      'We do not sell your personal information to third parties. We may share anonymized data for statistical purposes.';

  @override
  String get privacyUserRights => 'Your Rights';

  @override
  String get privacyUserRightsBody =>
      'You have the right to access, correct, or delete your personal data at any time through the Delete Account option in Settings.';

  @override
  String get termsLastUpdated => 'Last updated: February 2026';

  @override
  String get termsIntro =>
      'By using Rwanda Traffic Rule, you agree to the following terms. Rwanda Traffic Rule is an independent educational app that helps you prepare for your theory exam. We are not affiliated with any government or testing center.';

  @override
  String get termsAcceptance => 'Acceptance of Terms';

  @override
  String get termsAcceptanceBody =>
      'By creating an account and using this app, you agree to these terms. If you do not agree, please stop using this app.';

  @override
  String get termsUserAccount => 'User Account';

  @override
  String get termsUserAccountBody =>
      'You are responsible for maintaining the security of your account. Each account is linked to one phone number and one device. Sharing account information is not allowed.';

  @override
  String get termsContent => 'Exam Content';

  @override
  String get termsContentBody =>
      'All exam questions are for practice and education only. They are not a substitute for the official government exam. We cannot guarantee exam results. Rwanda Traffic Rule is not affiliated with any government agency.';

  @override
  String get termsPayment => 'Requesting Exam Access';

  @override
  String get termsPaymentBody =>
      'To access the app, contact help at 0788659575 or 0728877442.';

  @override
  String get termsTermination => 'Account Closure';

  @override
  String get termsTerminationBody =>
      'We reserve the right to close accounts that violate these terms. You may delete your account at any time in Settings.';

  @override
  String get aboutDisclaimer => 'Disclaimer';

  @override
  String get aboutDisclaimerText =>
      'Rwanda Traffic Rule is an independent educational app that helps you learn traffic rules and prepare for your theory exam. This app is not affiliated with, endorsed by, or connected to any government agency or testing center. All content in this app is for practice and education only.';

  @override
  String get profileCertificatesTitle => 'Certificates';

  @override
  String get profileCertificatesSubtitle =>
      'Certificates earned and progress to next';

  @override
  String get offlineBanner =>
      'You are offline. Cached data may not be up to date.';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get dataSynced => 'Data synced successfully';

  @override
  String get savedOffline =>
      'Saved offline. Will sync when you reconnect to the internet.';

  @override
  String certificateUniqueExamsPassed(Object count, Object total) {
    return '$count of $total unique exams passed';
  }

  @override
  String certificatePassMark(Object percent, Object required, Object total) {
    return 'Passing score: $required/$total ($percent%)';
  }

  @override
  String get certificateLatestAttempt => 'Latest';

  @override
  String certificateExamStatus(Object index) {
    return 'Exam $index';
  }

  @override
  String get certificateNotAttempted => 'Not attempted';

  @override
  String get consentTitle => 'Your survey is important';

  @override
  String get consentBody =>
      'Rwanda Traffic Rule collects and works with the following information to give you the best learning experience:\n\n• Phone number and name — to open an account and verify\n• Device fingerprint — a unique identifier assigned by a hash to protect your account\n• Exam answers and progress — to track your learning journey\n• Offline cache — so the app works without internet\n\nYour data is securely stored and never leaked to others. You can delete your account and all associated data at any time using the profile settings.';

  @override
  String get consentAccept => 'I understand and agree';

  @override
  String get consentReadPolicy => 'Read Privacy Policy';

  @override
  String get registerInvalidName => 'Name must contain only letters and spaces';

  @override
  String get registerInvalidPhone =>
      'Enter a valid phone number (e.g., 078... or +250 78...)';

  @override
  String get joinGroup => 'WhatsApp Group';

  @override
  String get joinGroupSubtitle => 'Join WhatsApp group';

  @override
  String get adminOfflineTooltip => 'Offline – show cached data';

  @override
  String get adminOfflineBadge => 'OFFLINE';

  @override
  String adminActiveLabel(Object count) {
    return '$count active';
  }

  @override
  String get adminFallbackName => 'Admin';

  @override
  String get adminNoNetworkError => 'No network. No cached data available.';

  @override
  String get commonErrorTitle => 'Error';

  @override
  String get exitAppTitle => 'Exit app';

  @override
  String get exitAppMessage => 'Are you sure you want to exit the app?';

  @override
  String get exitAppYes => 'Exit';

  @override
  String get exitAppNo => 'Stay';

  @override
  String get consentItemPhone => 'Phone number and name';

  @override
  String get consentItemPhoneDetail => 'Open account and verify';

  @override
  String get consentItemDevice => 'Device fingerprint';

  @override
  String get consentItemDeviceDetail =>
      'Unique identifier used to protect your account';

  @override
  String get consentItemProgress => 'Exam answers and progress';

  @override
  String get consentItemProgressDetail => 'Track your learning journey';

  @override
  String get consentItemCache => 'Offline cache';

  @override
  String get consentItemCacheDetail => 'App works without internet';

  @override
  String get consentSecurityNote =>
      'Your data is securely stored and never leaked to others.';

  @override
  String get consentIndependentTitle => 'Independent content';

  @override
  String get consentIndependentBody =>
      'This is an independent educational app. It is not affiliated with, endorsed by, or connected to any government or police level.';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardNotices => 'NOTICES';

  @override
  String get dashboardWhatsapp => 'WhatsApp Group';

  @override
  String get dashboardGazette => 'NEW GAZETTE';

  @override
  String get dashboardShare => 'Share App';

  @override
  String get dashboardProfileUnavailable => 'Account info unavailable';

  @override
  String get dashboardLoading => 'Loading access info…';

  @override
  String get dashboardSubscriptionUnavailable =>
      'Access info unavailable. Pull down to retry.';

  @override
  String get dashboardExpired => 'Learning access expired';

  @override
  String get dashboardDurationUnavailable => 'Unknown';

  @override
  String dashboardDuration(Object duration) {
    return 'Duration: $duration';
  }

  @override
  String get dashboardCached => 'Cached data · pull to refresh';

  @override
  String get dashboardNoticesUnavailable =>
      'Notices unavailable now. Try again later.';

  @override
  String get dashboardNoNotices => 'No notices';

  @override
  String get dashboardCopyLink => 'Copy link';

  @override
  String get dashboardLinkCopied => 'Link copied';

  @override
  String get dashboardOpenFailed => 'Unavailable. Try again.';

  @override
  String get dashboardComingSoon => 'Coming soon';

  @override
  String get dashboardUnderDevelopment => 'This feature is under development.';

  @override
  String get dashboardExamsLocked => 'Exams locked';

  @override
  String get dashboardRequestExamAccess => 'Request exam access here';

  @override
  String get paymentExamLanguage => 'Exam language';

  @override
  String get paymentExamLanguageHint =>
      'Choose exam language. This does not change app language.';

  @override
  String paymentAmountToPay(Object amount) {
    return 'Amount to pay: $amount RWF';
  }

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get paymentNotConfigured => 'Payment info not configured.';

  @override
  String get paymentUssdLabel => 'USSD dial code';

  @override
  String get paymentCopyCode => 'Copy code';

  @override
  String get paymentCodeCopied => 'Code copied';

  @override
  String get paymentCopyFailed =>
      'Code not copied. Try again or copy manually.';

  @override
  String get paymentUssdInstruction =>
      'Copy this code and use it on your phone to pay.';

  @override
  String get paymentPayNow => 'Pay now';

  @override
  String get paymentIntegrationPending =>
      'Payment info pending. Payment initiation method not connected; no payment approved.';

  @override
  String get paymentPreparationFailed =>
      'Payment preparation failed. Try again.';

  @override
  String paymentRecipient(Object method, Object name) {
    return '$method merchant: $name';
  }

  @override
  String get paymentVerifyRecipient =>
      'Before confirming payment, check that the recipient name shown on your phone matches what you entered here. If not, do not proceed.';

  @override
  String get dashboardGazetteSubtitle => 'Traffic rules';

  @override
  String get dashboardIremboSubtitle => 'Irembo services';

  @override
  String get guideTitle => 'GUIDELINES';

  @override
  String get guideWelcome => 'Welcome to RWANDA TRAFFIC RULE';

  @override
  String get guideAboutTitle => '1. App description';

  @override
  String get guideAboutBody =>
      'This app called ``RWANDA TRAFFIC RULE`` is an app that teaches traffic rules, consisting of questions asked in the provisional exam (learner permit)';

  @override
  String get guideUseTitle => '2. HOW THE APP WORKS';

  @override
  String get guideUseBody =>
      '1. To use this app you must first sign up when you first download it where you are asked to write your full name, your phone number; confirm and sign up approved\n\n2. When you already signed up you do not need to sign up again but instead sign up \\\"SIGN IN\\\" then you can enter your phone number then sign up \\\"APPROVED\\\" then you will be taken to dashboard where you will see items in the app.\n\n3. To start learning, sign up \\\"PRACTICE\\\" when you open it consists of 21 exams each consisting of 20 questions, but the first exam is free (free) the rest require payment.\n\n4. When you are practicing in this app, the row you make changes from green to red and when you mark it changes from green to red because practice always shows the correct answer so you can try to capture it (remember it) then sign up written \\\"NEXT\\\" go to the next question when you reach the end sign up written \\\"SUBMIT EXAM\\\" then you will see the score then choose another exam to learn';

  @override
  String get guideExamTitle =>
      '3. HOW YOU SEE QUESTIONS ON THE PROVISOIRE EXAM NYIRIZINA';

  @override
  String get guideExamBody =>
      'A. Go to the provisoireform on the machine First they will assess (evaluate) that you do not have disability, vision, hearing, reading and writing skills, proper identification number (identification) and that day\'s code, many others,... example fingerprint, on the thumb left index,...\n\nB. You will see these questions in this app as they are in the exam no questions they will ask you in the provisoire exam that are not in this app, If you choose an answer you will continue then the next question then you sign up \\\"NEXT\\\" continue with other questions when you finish you sign up \\\"SUBMIT EXAM\\\" then you will know the score so choose another exam to learn';

  @override
  String get guidePaymentTitle => '4. PAY TO UNLOCK ALL EXAMS';

  @override
  String get guidePaymentBody =>
      '1. As I explained earlier the first exam is free the other 20 require payment 1500Rwf to learn one month, 3000Rwf to learn three months or 5000 Rwf to learn six months on 0788659575/ 0728877442 or on MOMO PAY: 329494 merchant Alexis.\n\nTo pay using any number you choose is valid not mandatory to mention but if you use another number when you finish paying you will receive a message\n\nA. Pay using MTN:\na. *182*1*1*0788659575*1500#\nb. *182*8*1*329494*1500#\n\nB. Pay using Tigo or Airtel\na. *500*1*1*0728877442*1500#\nb. *182*8*1*88329494*1500#\nMerchant Alexis\n\n2. When you finish paying go check if you have connection (internet) wait two minutes then sign in before writing language on the screen then open practice you will see them unlocked all of them.\n\n4. OTHER MEANINGS THAT CAUSED YOU TO RECEIVE A MESSAGE:';

  @override
  String get guideOpenAccess => 'View payment prices';

  @override
  String get dashboardRefresh => 'Refresh access';

  @override
  String get dashboardRefreshDone => 'Access refreshed.';

  @override
  String get dashboardRefreshFailed =>
      'Failed to refresh access. Check your internet and try again.';

  @override
  String get resourcesTitle => 'Resources';

  @override
  String get resourcesDescription =>
      'Read gazette and signs in the app. These resources are included and readable without internet; choose your preferred language.';

  @override
  String get resourcesGazette => 'Gazette';

  @override
  String get resourcesRoadSigns => 'Signs';

  @override
  String get resourcesOfflinePdf => 'PDF • Read offline';

  @override
  String get resourcesReadError => 'Failed to open this resource. Try again.';

  @override
  String get resourcesPreviousPage => 'Previous page';

  @override
  String get resourcesNextPage => 'Next page';

  @override
  String get resourcesZoomOut => 'Zoom out';

  @override
  String get resourcesZoomIn => 'Zoom in';

  @override
  String get resourcesLoading => 'Resource loading…';

  @override
  String resourcesPageCount(Object page, Object total) {
    return 'Page $page of $total';
  }

  @override
  String get irTitle => 'Irembo services';

  @override
  String get irAlreadySubmitted =>
      'Request submitted. One request per service.';

  @override
  String get permisOption => 'Permis option';

  @override
  String get irOption => 'Irembo option';

  @override
  String get irServiceFee => 'Registration assistance fee';

  @override
  String get irPay => 'Pay';

  @override
  String get irWorkspace => 'Irembo request';

  @override
  String get irMyRequests => 'My Irembo requests';

  @override
  String get irNew => 'New request';

  @override
  String get irManual => 'Manual';

  @override
  String get irAutomatic => 'Automatic';

  @override
  String get irNotice =>
      'Help with exam registration. Registration is approved automatically.';

  @override
  String get irFullName => 'Full name';

  @override
  String get irPhone => 'Phone number';

  @override
  String get irNationalId => 'National ID number';

  @override
  String get irDob => 'Date of birth';

  @override
  String get irExamLanguage => 'Exam language';

  @override
  String get irLanguageHint => 'Example: Kinyarwanda, English, French';

  @override
  String get irDistrict => 'District where you want the exam done';

  @override
  String get irExamDate => 'Preferred exam date (optional)';

  @override
  String get irDateNotice => 'Preferred date is not the exam itinerary.';

  @override
  String get irProvisoireCode => 'Provisoire code';

  @override
  String get irCategory => 'Applicant category';

  @override
  String get irService => 'Service';

  @override
  String get irSelectRequest => 'Choose request';

  @override
  String get irReview => 'Review request';

  @override
  String get irConfirm => 'Submit request';

  @override
  String get irEdit => 'Edit request';

  @override
  String get irSaved => 'Request submitted';

  @override
  String get irReference => 'Request number';

  @override
  String get irStatus => 'Current status';

  @override
  String get irSubmitted => 'Submitted time';

  @override
  String get irUpdated => 'Updated time';

  @override
  String get irAssigned => 'Staff assigned';

  @override
  String get irUnassigned => 'No staff assigned';

  @override
  String get irPending => 'Pending';

  @override
  String get irInReview => 'Under review';

  @override
  String get irNeedsInformation => 'Missing information';

  @override
  String get irCompleted => 'Completed';

  @override
  String get irRejected => 'Rejected';

  @override
  String get irCancelled => 'Cancelled';

  @override
  String get irSearch => 'Search name, phone or ID';

  @override
  String get irFilters => 'Filters';

  @override
  String get irApply => 'Apply';

  @override
  String get irClear => 'Clear filters';

  @override
  String get irAll => 'All';

  @override
  String get irFrom => 'Submitted from';

  @override
  String get irTo => 'Submitted to';

  @override
  String get irNewest => 'Newest first';

  @override
  String get irOldest => 'Oldest first';

  @override
  String get irSort => 'Sort by';

  @override
  String get irEmpty => 'No matching request';

  @override
  String get irView => 'View details';

  @override
  String get irCall => 'Call applicant';

  @override
  String get irCopy => 'Copy';

  @override
  String get irCopyAll => 'Copy applicant details';

  @override
  String get irCopied => 'Copied';

  @override
  String get irCopyFailed => 'Copy failed. Try again.';

  @override
  String get irCallFailed => 'Call substitution app failed to open.';

  @override
  String get irMessages => 'Message required for applicant';

  @override
  String get irInternalNotes => 'Staff only notes';

  @override
  String get irInternalHint => 'Visible to staff only';

  @override
  String get irMessage => 'Submitted message to applicant';

  @override
  String get irReason => 'Reason (shows applicant)';

  @override
  String get irReasonRequired => 'Provide reason for pending request.';

  @override
  String get irAudit => 'Change history';

  @override
  String get irSave => 'Save changes';

  @override
  String get irRetry => 'Try again';

  @override
  String get irClose => 'Close';

  @override
  String get irRequired => 'These fields are required.';

  @override
  String get irInvalid => 'Check the info you entered.';

  @override
  String get irInvalidId => 'Enter exactly 16 digits.';

  @override
  String get irInvalidPhone => 'Enter a valid Rwandan phone number.';

  @override
  String get irUnavailable =>
      'Cannot access this service. Check internet and try again. Info entered was lost.';

  @override
  String get irConflict =>
      'This request was edited or submitted. Refresh the list before responding.';

  @override
  String get irNext => 'Next';

  @override
  String get irPrevious => 'Previous';

  @override
  String get irCreated => 'Request created';

  @override
  String get irChange => 'Change';

  @override
  String get irNoMessages => 'No message received.';

  @override
  String get irResults => 'Results found';

  @override
  String get irSelectDistrict => 'Search district';

  @override
  String get irEnglish => 'English';

  @override
  String get irFrench => 'French';

  @override
  String get irKinyarwanda => 'Kinyarwanda';

  @override
  String get irChooseService => 'Choose exam service';

  @override
  String get irChooseOption => 'Choose permit type';

  @override
  String get irProvisoireHelp => 'Provisional learner permit exam';

  @override
  String get irPermisHelp => 'Provisional learner permit exam';

  @override
  String get irContinue => 'Submit';

  @override
  String get irRequestsUnavailable => 'Your request is unavailable.';

  @override
  String get irServerSetup =>
      'Registration service not properly set up on server. Contact support or try again later.';

  @override
  String get irServiceUnavailable =>
      'Registration service currently unavailable. Try again.';

  @override
  String get irAccessUnavailable =>
      'Not authorized to view this bureau. Check your signed-in account.';

  @override
  String get irNoRequests => 'Choose a service to begin.';

  @override
  String get irStaffHelp =>
      'Search applicants, review request and track registration help.';

  @override
  String get waIntro =>
      'Let\'s build together. Choose a group to discuss questions and get study tips.';

  @override
  String get waManageIntro => 'Manage study groups for students.';

  @override
  String get waCached =>
      'These are cached groups. Joining a group or receiving new messages requires internet.';

  @override
  String get progressSaved =>
      'These are cached scores on this device. New scores will sync when internet is available.';

  @override
  String get irDeleteRequest => 'Delete request';

  @override
  String get irDeleteConfirm =>
      'Delete this request and its message permanently? This cannot be undone.';

  @override
  String get irSelectPage => 'Choose all requests on this page';

  @override
  String get irSelected => 'Selected';

  @override
  String get irDeleteSelected => 'Delete selected';

  @override
  String get irOfflineSaved =>
      'Saved request. Connect to internet to refresh, submit or delete request.';

  @override
  String get irDeleteUnavailable =>
      'Deletion unavailable on this server. Update Irembo backend routes and handler, then retry.';

  @override
  String get referralTitle => 'Refer & Earn';

  @override
  String get referralHeading => 'Better prepared, together.';

  @override
  String get referralDescription =>
      'Help a friend prepare for their driving theory exam. Send your personal invitation and follow successful registrations here.';

  @override
  String get referralSubtitle => 'Invite friends. Track your invitations.';

  @override
  String get referralYourCode => 'Your personal invitation code';

  @override
  String get referralInvite => 'Invite friends';

  @override
  String get referralCopy => 'Copy referral link';

  @override
  String get referralHistory => 'Referral history';

  @override
  String get referralTotal => 'Total referrals';

  @override
  String get referralConfirmed => 'Successful registration';

  @override
  String get referralPending => 'Pending';

  @override
  String get referralRewardsDisabled =>
      'Referral tracking is active. Rewards are not configured yet, so invitations do not currently grant money or exam access.';

  @override
  String get referralEmpty =>
      'Your invitations will appear here when friends create their accounts using your link.';

  @override
  String get referralLoadError =>
      'We couldn’t load your invitations. Check your connection and try again.';

  @override
  String get referralInviteMessage =>
      'Prepare for your Rwanda driving theory exam with Rwanda Traffic Rules! Get the app and start learning using my invitation:';

  @override
  String get referralShareUnavailable =>
      'Sharing isn’t available here. Use Copy referral link to send your invitation.';

  @override
  String get referralMore => 'Load more';

  @override
  String get adminReferrals => 'Referrals';

  @override
  String get adminReferralSearch => 'Search by name, referral code or phone';

  @override
  String get adminReferralInvitees => 'Invited users';

  @override
  String get adminReferralDeletedUser => 'Deleted account';

  @override
  String get dashboardReferrals => 'Refer & Earn';
}
