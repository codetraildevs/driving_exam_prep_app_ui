// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kinyarwanda (`rw`).
class AppLocalizationsRw extends AppLocalizations {
  AppLocalizationsRw([String locale = 'rw']) : super(locale);

  @override
  String get appTitle => 'Kwiga amategeko y\'umuhanda';

  @override
  String get languageSelectTitle => 'Hitamo ururimi rwawe';

  @override
  String get languageSelectSubtitle =>
      'Ushobora guhindura ibi nyuma mu igenamiterere';

  @override
  String get languageSelectConfirm => 'Komeza';

  @override
  String get homeWelcomeBack => 'Murakaza neza 👋';

  @override
  String homeGreeting(String userName) {
    return '$userName';
  }

  @override
  String get homeContinueMessage =>
      'Komeza kwiga amategeko y\'umuhanda uyu munsi.';

  @override
  String get homeContinueLearning => 'Komeza kwiga';

  @override
  String homeAccessActive(int daysLeft) {
    return 'Uburenganzira burahari - hasigaye iminsi $daysLeft';
  }

  @override
  String homePaymentTier(String tier) {
    return 'Igiciro: $tier';
  }

  @override
  String homePracticeSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imyitozo $count',
      one: 'Imyitozo 1',
      zero: 'Nta myitozo',
    );
    return '$_temp0';
  }

  @override
  String get homePractices => 'Imyitozo';

  @override
  String get homePracticesSubtitle => 'Ibibazo by\'imyitozo';

  @override
  String get homeCourses => 'Amasomo';

  @override
  String get homeCoursesSubtitle => 'Modire z\'amasomo';

  @override
  String get homeMockExams => 'Ikizamini cy\'imyitozo';

  @override
  String get homeMockExamsSubtitle => 'Suzuma ubumenyi';

  @override
  String get homeProgress => 'Iterambere';

  @override
  String get homeProgressSubtitle => 'Kurikirana imikorere';

  @override
  String get homeShareApp => 'Sangira app';

  @override
  String get homeShareAppSubtitle => 'Tumira inshuti';

  @override
  String get settingsTitle => 'Igenamiterere';

  @override
  String get settingsPreferences => 'Amahitamo';

  @override
  String get settingsDarkMode => 'Uburyo bw\'umwijima';

  @override
  String get settingsDarkModeSubtitle =>
      'Koresha insanganyamatsiko y\'umwijima';

  @override
  String get settingsNotifications => 'Kumenyesha';

  @override
  String get settingsNotificationsSubtitle =>
      'Kwakira ibiwibutso bya buri munsi';

  @override
  String get settingsLanguage => 'Ururimi';

  @override
  String get settingsAbout => 'Ibyerekeye';

  @override
  String get settingsAboutApp => 'Ibyerekeye app y\'amategeko y\'umuhanda';

  @override
  String settingsVersion(String version) {
    return 'Verisiyo $version';
  }

  @override
  String get settingsPrivacyPolicy => 'Politiki y\'ibanga';

  @override
  String get settingsPrivacyPolicySubtitle => 'Soma politiki yacu y\'ibanga';

  @override
  String get settingsTermsOfService => 'Amabwiriza y\'ikoreshwa';

  @override
  String get settingsTermsOfServiceSubtitle => 'Soma amabwiriza yacu';

  @override
  String get settingsData => 'Amakuru';

  @override
  String get settingsResetProgress => 'Gusubiramo iterambere';

  @override
  String get settingsResetProgressSubtitle => 'Siba amakuru yawe yose';

  @override
  String get settingsResetConfirmTitle => 'Gusubiramo iterambere';

  @override
  String get settingsResetConfirmMessage =>
      'Uzi neza ko ushaka gusubiramo iterambere ryawe ryose? Iki gikorwa ntigishobora gusubizwaho.';

  @override
  String get settingsResetSuccess => 'Iterambere ryasubiwemo neza';

  @override
  String get settingsSelectLanguage => 'Hitamo ururimi';

  @override
  String get commonCancel => 'Hagarika';

  @override
  String get commonConfirm => 'Emeza';

  @override
  String get commonReset => 'Subiramo';

  @override
  String get landingHeroTitle => 'Menya amategeko y\'umuhanda byoroshye';

  @override
  String get landingHeroSubtitle =>
      'Witegure neza. Witozere ku bibazo nyabyo by\'ikizamini. Kurikirana iterambere ryawe kandi utsinde ikizamini cy\'uruhushya rwo gutwara byizewe.';

  @override
  String get landingGetStarted => 'Tangira';

  @override
  String get landingAlreadyHaveAccount => 'Usanzwe ufite konti? Injira';

  @override
  String get landingWhyUseApp => 'Kuki wakoresha app yacu?';

  @override
  String get landingLearnRules => 'Kwiga amategeko';

  @override
  String get landingLearnRulesDesc =>
      'Ibisobanuro bisobanutse by\'amategeko yose y\'umuhanda n\'ibimenyetso.';

  @override
  String get landingPracticeExams => 'Ikizamini cy\'imyitozo';

  @override
  String get landingPracticeExamsDesc =>
      'Kora ibizamini by\'imyitozo bisa n\'ikizamini nyacyo.';

  @override
  String get landingTrackProgress => 'Kurikirana iterambere';

  @override
  String get landingTrackProgressDesc =>
      'Kurikirana imikorere yawe no kunoza aho ugoyeho.';

  @override
  String get landingHowItWorks => 'Uko bikora';

  @override
  String get landingStep1 => 'Fungura konti yawe y\'ubuntu';

  @override
  String get landingStep2 => 'Tangira kwiga amategeko y\'umuhanda';

  @override
  String get landingStep3 => 'Kora ibizamini by\'imyitozo';

  @override
  String get landingStep4 => 'Tsinda ikizamini nyacyo wizeye';

  @override
  String get landingReadyTitle => 'Witeguye gutsinda ikizamini cy\'ubutwara?';

  @override
  String get landingStartLearning => 'Tangira kwiga ubu';

  @override
  String get homeServices => 'Serivisi';

  @override
  String get authAppName => 'AMATEGEKO Y\'UMUHANDA RWANDA';

  @override
  String get authSubtitle => 'Urubuga rwemewe rwo kwiga gutwara';

  @override
  String get loginTitle => 'Injira kuri konti yawe';

  @override
  String get loginSubtitle =>
      'Andika numero ya telefoni yawe yanditswe kugira ngo ukomeze.';

  @override
  String get authNeedHelp => 'Ukeneye ubufasha?';

  @override
  String get loginHelpText =>
      'Ku bibazo bya konti cyangwa ibibazo, wahamagara:';

  @override
  String get authPhoneNumber => 'Numero ya telefoni';

  @override
  String get authPhoneHint => '0788 000 000';

  @override
  String get authContinue => 'Komeza';

  @override
  String get loginNoAccount => 'Nta konti ufite? ';

  @override
  String get loginSignUp => 'Iyandikishe';

  @override
  String get authSecureTag => 'Umutekano • Byihuse • App yemewe';

  @override
  String get loginPhoneRequired => 'Nyamuneka andika numero ya telefoni yawe';

  @override
  String get registerTitle => 'Fungura konti yawe';

  @override
  String get registerSubtitle =>
      'Iyandikishe ukoresheje izina ryawe ryuzuye na numero ya telefoni kugira ngo utangire kwiga.';

  @override
  String get registerHelpText =>
      'Ku bibazo byo kwiyandikisha cyangwa ibibazo, wahamagara:';

  @override
  String get authFullName => 'Izina ryuzuye';

  @override
  String get authFullNameHint => 'Andika izina ryawe ryuzuye';

  @override
  String get registerTerms =>
      'Nemeye amabwiriza y\'ikoreshwa n\'amabwiriza y\'ibanga.';

  @override
  String get registerSignUp => 'Iyandikishe';

  @override
  String get registerHaveAccount => 'Usanzwe ufite konti? ';

  @override
  String get registerLogIn => 'Injira';

  @override
  String get registerFillAllFields => 'Nyamuneka uzuza imyanya yose';

  @override
  String get registerAgreeTerms => 'Nyamuneka emera amabwiriza n\'ibisabwa';

  @override
  String get forgotPasswordTitle =>
      'Gusubiramo ijambo ry\'ibanga ntibibashoboka';

  @override
  String get forgotPasswordDescription =>
      'Sisitemu ikoresha numero ya telefoni n\'ihuza ry\'igikoresho (nta gusubiramo ijambo ry\'ibanga).';

  @override
  String get forgotPasswordBackToLogin => 'Subira ku kwinjira';

  @override
  String get navHome => 'Ahabanza';

  @override
  String get navPractice => 'Imyitozo';

  @override
  String get navProgress => 'Iterambere';

  @override
  String get navProfile => 'Umwirondoro';

  @override
  String get practiceTitle => 'Ikizamini cy\'imyitozo';

  @override
  String get practiceCategorySpeedLimits => 'Umuvuduko ntarengwa';

  @override
  String get practiceCategoryRoadSigns => 'Ibimenyetso by\'umuhanda';

  @override
  String get practiceCategoryLaneControl => 'Kuyobora umurongo';

  @override
  String get practiceCategoryParkingRules => 'Amategeko yo guparika';

  @override
  String get practiceStart => 'Tangira →';

  @override
  String get quizComplete => 'Ikizamini kirangiye!';

  @override
  String quizScore(int score) {
    return 'Amanota: $score%';
  }

  @override
  String quizResult(int correct, int total) {
    return 'Wasubije neza $correct mu $total';
  }

  @override
  String get quizBackToPractice => 'Subira mu myitozo';

  @override
  String quizQuestion(int current, int total) {
    return 'Ikibazo $current/$total';
  }

  @override
  String get quizFinish => 'Rangiza ikizamini';

  @override
  String get quizNextQuestion => 'Ikibazo gikurikira';

  @override
  String get examMockExam => 'Ikizamini cy\'imyitozo';

  @override
  String get examInstructions => 'Amabwiriza y\'ikizamini';

  @override
  String get examTimeLimit => 'Igihe ntarengwa';

  @override
  String get examTimeLimitDesc => 'Iminota 30 yose hamwe ku bibazo 20';

  @override
  String get examQuestionCount => 'Ibibazo 20';

  @override
  String get examQuestionCountDesc =>
      'Uburyo bwo guhitamo bwinshi ufite amahitamo 4 buri kimwe';

  @override
  String get examPassingScore => 'Amanota yo gutsinda';

  @override
  String get examPassingScoreDesc =>
      'Ukeneye 70% cyangwa hejuru kugira ngo utsinde';

  @override
  String get examNoGoingBack => 'Nta gusubira inyuma';

  @override
  String get examNoGoingBackDesc => 'Ntushobora gusubira ku bibazo byashize';

  @override
  String get examWarning =>
      'Menya neza ko ufite interineti ihamye kandi utazahagarikwa';

  @override
  String get examStartExam => 'Tangira ikizamini';

  @override
  String get examSubmit => 'Ohereza ikizamini';

  @override
  String get examCongratulations => 'Bihebwe!';

  @override
  String get examGoodEffort => 'Ugerageje neza';

  @override
  String get examPassedMessage => 'Watsinze ikizamini neza cyane!';

  @override
  String get examFailedMessage => 'Komeza witozera kugira ngo wongere amanota';

  @override
  String get examYourScore => 'Amanota yawe';

  @override
  String get examCorrect => 'Ibisubizo byiza';

  @override
  String get examAccuracy => 'Ubushobozi';

  @override
  String get examNeedMorePractice =>
      'Ukeneye 70% kugira ngo utsinde. Witozere byinshi!';

  @override
  String get examBadgeEarned => 'Wabonye ikimenyetso cyo gutsinda ikizamini!';

  @override
  String get examRetakeTest => 'Subiramo ikizamini';

  @override
  String get examBackHome => 'Subira ahabanza';

  @override
  String get progressTitle => 'Iterambere ryawe';

  @override
  String get progressPerformanceSummary => 'Incamake y\'imikorere';

  @override
  String get progressTotalAttempts => 'Ibigeragezo byose';

  @override
  String get progressBestScore => 'Amanota meza';

  @override
  String get progressAverageScore => 'Amanota y\'umumaro';

  @override
  String get progressSignsLearned => 'Ibimenyetso byigishijwe';

  @override
  String get progressRecentExams => 'Ibizamini bya vuba';

  @override
  String get progressOverall => 'Iterambere rusange';

  @override
  String get progressComplete => 'Byarangiye';

  @override
  String get progressAvgScore => 'Man. y\'umum.';

  @override
  String get progressSigns => 'Ibimenyetso';

  @override
  String get progressPassed => 'Yatsinze';

  @override
  String get progressExcellent => 'Byiza cyane';

  @override
  String progressMockExam(int number) {
    return 'Ikizamini cy\'imyitozo $number';
  }

  @override
  String get progressPracticeQuiz => 'Ikizamini cyo kwitozera';

  @override
  String get profileTitle => 'Umwirondoro';

  @override
  String get profileLocation => 'Kigali, Rwanda';

  @override
  String get profileOverallProgress => 'Iterambere rusange ry\'amasomo';

  @override
  String profileModulesCompleted(int completed, int total) {
    return '$completed/$total Modire zarangiye';
  }

  @override
  String get profileAccount => 'Konti';

  @override
  String get profileSettings => 'Igenamiterere';

  @override
  String get profileSettingsSubtitle => 'Kumenyesha, ururimi, ibanga';

  @override
  String get profileDeleteAccount => 'Siba konti';

  @override
  String get profileSignOut => 'Sohoka';

  @override
  String get profileDeleteConfirmTitle => 'Siba konti';

  @override
  String get profileDeleteConfirmMessage =>
      'Uzi neza ko ushaka gusiba konti yawe burundu? Iki gikorwa ntigishobora gusubizwaho.';

  @override
  String get profileDelete => 'Siba';

  @override
  String get certificatesTitle => 'Impamyabumenyi zanjye';

  @override
  String get certificatesAchievements => 'Ibyo wagezeho';

  @override
  String get certificatesEarned => 'Yarabonye';

  @override
  String get certificatesPending => 'Hitegereje';

  @override
  String get certificatesInProgress => 'Biracyakorwa';

  @override
  String get certificateRoadSignsMastery => 'Kumenya ibimenyetso by\'umuhanda';

  @override
  String get certificateTrafficRulesTest =>
      'Ikizamini cy\'amategeko y\'umuhanda';

  @override
  String get certificateDefensiveDriving => 'Gutwara mu mutekano';

  @override
  String get signsTitle => 'Ibimenyetso by\'umuhanda';

  @override
  String get signsSearchHint => 'Shakisha ibimenyetso by\'umuhanda...';

  @override
  String get signsNotFound => 'Nta bimenyetso by\'umuhanda byabonetse';

  @override
  String get signsLearned => 'Byarigishijwe';

  @override
  String get signsAll => 'Byose';

  @override
  String get signDetailTitle => 'Ikimenyetso cy\'umuhanda';

  @override
  String get signDetailNotFound => 'Ikimenyetso ntigibonetse';

  @override
  String get signDetailDescription => 'Ibisobanuro';

  @override
  String get signDetailScenario => 'Igihe cy\'ubuzima nyacyo';

  @override
  String get signDetailLearned => 'Wigeze iki kimenyetso!';

  @override
  String get signDetailMarkAsLearned => 'Shyira nk\'icyigishijwe';

  @override
  String get signDetailMarkedSuccess =>
      'Ikimenyetso cyashyizwe nk\'icyigishijwe!';

  @override
  String get subscriptionTitle => 'Uburenganzira bw\'ibizamini by\'imyitozo';

  @override
  String get subscriptionSubtitle => 'Fungura ibizamini byose by\'imyitozo';

  @override
  String get subscriptionCurrentPlan => 'Gahunda yawe ubu';

  @override
  String get subscriptionNoPlan => 'Nta gahunda ikoreshwa';

  @override
  String get subscriptionMonth1 => 'Ukwezi 1';

  @override
  String get subscriptionMonth3 => 'Amezi 3';

  @override
  String get subscriptionMonth6 => 'Amezi 6';

  @override
  String subscriptionPrice(int amount) {
    return '$amount RWF';
  }

  @override
  String get subscriptionRequestAccess => 'Saba uburenganzira';

  @override
  String get subscriptionRequestSent =>
      'Ubusabe bwawe bwoherejwe. Uzakezwa umara kwemeza kwishyura.';

  @override
  String get subscriptionPaymentInstructions => 'Amabwiriza yo kwishyura';

  @override
  String get subscriptionPaymentMomo => 'MoMo Pay: 323294';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788657595';

  @override
  String get subscriptionHelpCall => 'Hamagara: 0788657595';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788657595';

  @override
  String get subscriptionChoosePlan => 'Hitamo gahunda';

  @override
  String get subscriptionCurrency => 'Ifaranga: RWF';

  @override
  String get subscriptionAccessActive => 'Uburenganzira burahari';

  @override
  String subscriptionExpires(String date) {
    return 'Igihe kirangira: $date';
  }

  @override
  String subscriptionDays(int days) {
    return 'Iminsi $days';
  }

  @override
  String get subscriptionNeedHelp => 'Ukeneye ubufasha?';

  @override
  String subscriptionGetAccess(int count) {
    return 'Bona uburenganzira bw\'ibizamini $count+ by\'imyitozo';
  }

  @override
  String get adminDashboard => 'Aho abayobozi bakora';

  @override
  String get adminUsers => 'Abakoresha';

  @override
  String get adminAccess => 'Gucunga uburenganzira';

  @override
  String get adminProgress => 'Iterambere ry\'abakoresha';

  @override
  String get adminTotalUsers => 'Abakoresha bose';

  @override
  String get adminActiveSubscriptions => 'Aboneri ikoreshwa';

  @override
  String get adminUsersByLanguage => 'Abakoresha nk\'ururimi';

  @override
  String get adminRecentRegistrations => 'Iyandikishe ryashya';

  @override
  String get adminGrantAccess => 'Ha uburenganzira';

  @override
  String get adminCallUser => 'Hamagara umukoresha';

  @override
  String get adminCallNotes => 'Amanotisi y\'ikiganiro';

  @override
  String get adminLastCalled => 'Hamagawe ubwa nyuma';

  @override
  String get adminNoAccess => 'Nta burenganzira';

  @override
  String get adminHasAccess => 'Afite uburenganzira';

  @override
  String get adminAccessExpired => 'Uburenganzira bwarangiye';

  @override
  String adminAccessExpires(String date) {
    return 'Burangira: $date';
  }

  @override
  String get adminSearchUsers => 'Shakisha abakoresha...';

  @override
  String get adminFilterAll => 'Bose';

  @override
  String get adminFilterHasAccess => 'Bafite uburenganzira';

  @override
  String get adminFilterNoAccess => 'Nta burenganzira';

  @override
  String get adminManageUsers => 'Gucunga abakoresha';

  @override
  String get adminManageAccess => 'Gucunga uburenganzira';

  @override
  String get adminViewProgress => 'Reba iterambere';

  @override
  String adminRegistrationDate(String date) {
    return 'Yiyandikishije: $date';
  }

  @override
  String get adminEnterCallNotes => 'Andika amanotisi y\'ikiganiro...';

  @override
  String get adminSubmitCall => 'Ohereza';

  @override
  String get adminCallLogged => 'Ikiganiro cyanditswe neza';

  @override
  String get adminAccessGranted => 'Uburenganzira bwatanzwe neza';

  @override
  String get adminSelectTier => 'Hitamo urwego rw\'uburenganzira';

  @override
  String get adminCustomDays => 'Iminsi yihariye';

  @override
  String get adminPaymentAmount => 'Amafaranga (RWF)';

  @override
  String get adminEnterDays => 'Injiza umubare w\'iminsi';

  @override
  String get adminEnterAmount => 'Injiza amafaranga mu RWF';

  @override
  String get adminOrCustom => 'Cyangwa shyiramo iminsi yihariye';

  @override
  String get adminPendingRequests => 'Ubusabe bwo kwishyura buriho';

  @override
  String get adminAllUsersList => 'Abakoresha bose';

  @override
  String get adminInvalidAmount =>
      'Nyamuneka injiza amafaranga akwiye arengeje 0';

  @override
  String get adminInvalidDays =>
      'Nyamuneka injiza umubare w\'iminsi ukwiye arengeje 0';

  @override
  String get adminAccessRevoked => 'Uburenganzira bwavanwe';

  @override
  String get adminNoUsers => 'Nta mukoresha wabonetse';

  @override
  String get examListTitle => 'Ibizamini by\'imyitozo';

  @override
  String get examFree => 'UBUNTU';

  @override
  String get examPaid => 'BIRISHYURWA';

  @override
  String get examLocked => 'Bifunze';

  @override
  String examQuestions(int count) {
    return 'Ibibazo $count';
  }

  @override
  String get quizProgress => 'Iterambere';

  @override
  String quizAnswered(int answered, int total) {
    return 'Byasubijwe: $answered/$total';
  }

  @override
  String get quizSubmitPractice => 'Ohereza imyitozo';

  @override
  String get quizPrevious => 'Inyuma';

  @override
  String get quizNext => 'Imbere';

  @override
  String quizTimeRemaining(String time) {
    return 'Igihe: $time';
  }

  @override
  String get quizResults => 'Ibisubizo by\'ikizamini';

  @override
  String get quizPassed => 'Watsinze!';

  @override
  String get quizFailed => 'Komeza witozera';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Ikibazo $current kuri $total';
  }

  @override
  String get quizSubmitConfirmTitle => 'Ohereza ikizamini?';

  @override
  String quizSubmitConfirmMessage(int answered, int total) {
    return 'Wasubije ibibazo $answered kuri $total. Uzi neza ko ushaka kohereza?';
  }

  @override
  String get quizTimeUp =>
      'Igihe kirangiye! Ikizamini cyoherejwe by\'ikirenga.';

  @override
  String get quizReviewAnswers => 'Reba ibisubizo';

  @override
  String get quizRetake => 'Subiramo ikizamini';

  @override
  String get profileRole => 'Uruhare';

  @override
  String get profileLanguage => 'Ururimi rwitonderwa';

  @override
  String profileRegistered(String date) {
    return 'Yiyandikishije: $date';
  }

  @override
  String get profileAccessStatus => 'Uko uburenganzira buri';

  @override
  String get profileExamHistory => 'Amateka y\'ibizamini';

  @override
  String get profileCallHistory => 'Amateka y\'ibiganiro';

  @override
  String get paymentInstructionsTitle => 'Amabwiriza yo kwishyura';

  @override
  String get paymentMomoPayNumber => 'MoMo Pay: 323294';

  @override
  String get paymentMomoPayDial => 'Kwishyura na MoMo Pay, kanda: *182*1*1*323294*amafaranga#';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788657595';

  @override
  String get paymentMobileMoneyDial => 'Kwishyura na Mobile Money, kanda: *182*8*1*0788657595*amafaranga#';

  @override
  String get paymentHelpText =>
      'Ukeneye ubufasha? Hamagara cyangwa WhatsApp: 0788657595';

  @override
  String get paymentHelpContact =>
      'Urashobora kopi cyangwa guhamagara: 0788657595 cyangwa WhatsApp: 0788657595 kugira ubufasha.';

  @override
  String get paymentError =>
      'Ubusabe bwo kwishyura bwananiranye. Nyamuneka wishyure ukoresha amabwiriza hano epfo.';

  @override
  String get paymentCopyNumber => 'Kopi nimero';

  @override
  String get paymentCallNumber => 'Hamagara 0788657595';

  @override
  String get paymentWhatsApp => 'WhatsApp: Ohereza ubutumwa';

  @override
  String get paymentWhatsAppMessage =>
      'Saba uburenganzira bwo gukoresha porogaramu y\'ikizamini cyo gutwara';

  @override
  String get paymentRequestExists =>
      'Ubusabe bwo kwishyura kuri iyi gahato buriho. Tegereza ko ubuzima bwawe buremwa cyangwa vugana na serivisi.';

  @override
  String get commonError => 'Hari ikibazo cyabaye. Ongera ugerageze.';

  @override
  String get commonRetry => 'Ongera ugerageze';

  @override
  String get adminTierLabel => 'Urwego';

  @override
  String get adminExpiresLabel => 'Burangira';

  @override
  String get adminRenewAccess => 'Subiramo / Ongerera uburenganzira';

  @override
  String get adminManagePlatform => 'Gucunga urubuga';

  @override
  String get adminManageExams => 'Gucunga ibizamini';

  @override
  String get adminManageExamsDesc =>
      'Reba no gucunga ibizamini byose byo kwimenyereza';

  @override
  String get adminManageUsersDesc =>
      'Reba, shakisha no gucunga abakoresha bose';

  @override
  String get adminAccessCodesDesc =>
      'Gucunga amakoodi y\'uburenganzira n\'ubwishyu';

  @override
  String get adminQuickStats => 'Imibare y\'igihe gito';

  @override
  String get adminActionsTitle => 'Ibikorwa bya Admin';

  @override
  String get adminTotalPractices => 'Imyitozo yose';

  @override
  String get adminManagePlatformDesc =>
      'Gucunga urubuga rw\'amategeko y\'umuhanda';

  @override
  String get adminNotifications => 'Imenyesha';

  @override
  String get settingsAppearance => 'Iyongerera';

  @override
  String get settingsAppearanceDesc => 'Hitamo uko porogaramu igaragara';

  @override
  String get settingsThemeSystem => 'Sisitemu';

  @override
  String get settingsThemeLight => 'Urumuri';

  @override
  String get settingsThemeDark => 'Umukara';

  @override
  String get examWrong => 'Binyuranye';

  @override
  String get examTimeSpent => 'Igihe';

  @override
  String get profileLogoutConfirmTitle => 'Gusohoka?';

  @override
  String get profileLogoutConfirmMessage => 'Urashaka gusohoka mu konti yawe?';

  @override
  String get profileDeleteInstructions =>
      'Mbere yo gusiba konti yawe:\n• Ibisubizo byawe byose bizasibwa burundu\n• Abonement yawe izakurwa\n• Iyi ntambwe ntigira ingaruka\n• Uzakenera kwiyandikisha nanone kugirango ukoreshe porogaramu';

  @override
  String get progressExamsTaken => 'Ibizamini byakozwe';

  @override
  String get progressPassedCount => 'Byakunze';

  @override
  String get progressFailedCount => 'Byanze';

  @override
  String get progressPassRate => 'Ijanisha ry\'imenyekana';

  @override
  String get progressNoExams =>
      'Nta bizamini birakozwe. Tangira gukora ibibazo!';

  @override
  String get certificateReadyTitle => 'Witeguye ikizamini cy\'ukuri!';

  @override
  String certificateReadySubtitle(int count) {
    return 'Warashize $count ibizamini. Witeguye ikizamini cy\'uburenganzira bwo gutwara.';
  }

  @override
  String get certificateIremboLink =>
      'Iyandikishe ku kizamini cya leta kuri irembo.gov.rw';

  @override
  String get certificateIremboDesc =>
      'Kanda hepfo iyandikishe mu kizamini cya mudasobwa cy\'uburenganzira bwo gutwara bw\'igerageza';

  @override
  String certificateExamsNeeded(int needed) {
    return 'Shira $needed ibizamini byindi kugirango ubone icyangombwa cyawe';
  }

  @override
  String certificateProgressLabel(int passed, int total) {
    return '$passed mu $total ibizamini bisabwa byashize';
  }

  @override
  String get adminSortAsc => 'Bikuze mbere';

  @override
  String get adminSortDesc => 'Bishya mbere';

  @override
  String get adminFilterToday => 'Uyu munsi';

  @override
  String get adminDateRange => 'Igihe cy\'amakuru';

  @override
  String get adminFilterRole => 'Uruhare';

  @override
  String get adminBlockUser => 'Ziba Umukoreshwa';

  @override
  String get adminUnblockUser => 'Fungura Umukoreshwa';

  @override
  String get adminDeleteUserAction => 'Siba Umukoreshwa';

  @override
  String adminBlockUserConfirm(String name) {
    return 'Ziba $name? Bazatakaza uburenganzira bwo kwinjira.';
  }

  @override
  String adminDeleteUserConfirm(String name) {
    return 'Siba $name burundu? Amakuru yabo yose azasibwa.';
  }

  @override
  String get adminUserBlocked => 'Umukoreshwa yazibwe neza';

  @override
  String get adminUserUnblocked => 'Umukoreshwa yafunguriwe neza';

  @override
  String get adminUserDeleted => 'Umukoreshwa yasibwe neza';

  @override
  String get adminMustBlockFirst =>
      'Ugomba kubanza guziba umukoreshwa mbere yo kumusiба.';

  @override
  String get adminBlockAccess => 'Ziba Uburenganzira';

  @override
  String get adminDeleteAccess => 'Siba Uburenganzira';

  @override
  String get adminBlockAccessConfirm =>
      'Ziba kode y\'uburenganzira? Umukoreshwa azatakaza uburenganzira vuba.';

  @override
  String get adminDeleteAccessConfirm => 'Siba kode y\'uburenganzira burundu?';

  @override
  String get adminAccessBlocked => 'Kode y\'uburenganzira yazibwe';

  @override
  String get adminAccessDeleted => 'Kode y\'uburenganzira yasibwe';

  @override
  String adminPage(int page, int total) {
    return 'Urupapuro $page rwa $total';
  }

  @override
  String get adminLearningLanguage => 'Ururimi rwigwa';

  @override
  String get adminIsBlocked => 'Yazibwe';

  @override
  String get adminIsActive => 'Birakora';

  @override
  String get generalCopied => 'Byakopeshejwe!';

  @override
  String get adminRetry => 'Ongera ugerageze';

  @override
  String get languageSelectDescription =>
      'Ushobora guhindura ibi nyuma mu igenamiterere — kubona amakuru y\'umuhanda n\'inzira mu rurimi rwawe.';

  @override
  String get languageSelectDeviceLanguage => 'Koresha ururimi rw\'igikoresho';

  @override
  String get languageSelectHelpTooltip => 'Ubufasha ku rurimi';

  @override
  String get languageSelectMaybeLater => 'Birashoboka nyuma';

  @override
  String get languageSelectHelpTitle => 'Kuki wahitamo ururimi?';

  @override
  String get languageSelectHelpContent =>
      'Guhitamo ururimi bituma amakuru, amakarita, n\'amajwi bigaragazwa mu rurimi rwawe. Ushobora guhindura ibi nyuma mu igenamiterere.';

  @override
  String get commonGotIt => 'Nabyumvise';

  @override
  String get languageSelectDialogTitle => 'Hitamo ururimi';

  @override
  String get examNotFound => 'Ikizamini ntigibonetse';

  @override
  String errorWithDetail(String detail) {
    return 'Ikosa: $detail';
  }

  @override
  String errorUnexpected(String detail) {
    return 'Ikosa ridateganijwe: $detail';
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
  String get examSampleQ1 => 'Umuvuduko ntarengwa ku muhanda nini ni uwuhe?';

  @override
  String get examSampleQ1A1 => '90 km/h';

  @override
  String get examSampleQ1A2 => '100 km/h';

  @override
  String get examSampleQ1A3 => '110 km/h';

  @override
  String get examSampleQ1A4 => '120 km/h';

  @override
  String get examSampleQ2 =>
      'Icyo itara ry\'umuhanda ritukura rishaka kuvuga ni iki?';

  @override
  String get examSampleQ2A1 => 'Hagarara ako kanya';

  @override
  String get examSampleQ2A2 => 'Komeza';

  @override
  String get examSampleQ2A3 => 'Witegure guhagarara';

  @override
  String get examSampleQ2A4 => 'Hindura inzira';

  @override
  String get examSampleQ3 =>
      'Ushobora guparika kure kangahe y\'umuyoboro w\'amazi y\'umuriro?';

  @override
  String get examSampleQ3A1 => 'Metero 1';

  @override
  String get examSampleQ3A2 => 'Metero 3';

  @override
  String get examSampleQ3A3 => 'Metero 5';

  @override
  String get examSampleQ3A4 => 'Metero 10';
}
