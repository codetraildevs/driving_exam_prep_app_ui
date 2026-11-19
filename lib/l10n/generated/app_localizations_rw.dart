// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kinyarwanda (`rw`).
class AppLocalizationsRw extends AppLocalizations {
  AppLocalizationsRw([String locale = 'rw']) : super(locale);

  @override
  String get appTitle => 'Rwanda Traffic Rule';

  @override
  String get languageSelectTitle => 'Hitamo ururimi rwawe';

  @override
  String get languageSelectSubtitle =>
      'Ushobora guhindura ururimi uciiye mw\'igenamiterere';

  @override
  String get languageSelectConfirm => 'Komeza';

  @override
  String get homeWelcomeBack => 'Murakaza neza 👋';

  @override
  String homeGreeting(Object userName) {
    return '$userName';
  }

  @override
  String get homeContinueMessage =>
      'Komeza kwiga amategeko y\'umuhanda uyu munsi.';

  @override
  String get homeContinueLearning => 'Komeza kwiga';

  @override
  String homeAccessActive(Object daysLeft) {
    return 'Uburenganzira bwo kwiga - hasigaye iminsi $daysLeft';
  }

  @override
  String homePaymentTier(Object tier) {
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
  String get homePracticesSubtitle => 'Ibizamini byakozwe';

  @override
  String get homeCourses => 'Amasomo';

  @override
  String get homeCoursesSubtitle => 'Amasomo ku mategeko y\'umuhanda';

  @override
  String get homeMockExams => 'Ibizamini byo kwitorezaho';

  @override
  String get homeMockExamsSubtitle => 'Isuzuma ubumenyi';

  @override
  String get homeProgress => 'Iterambere';

  @override
  String get homeProgressSubtitle => 'Kurikirana imikorere';

  @override
  String get homeShareApp => 'Sangiza porogaramu';

  @override
  String get homeShareAppSubtitle => 'Tumira inshuti';

  @override
  String get homeShareAppMessage =>
      'Download Rwanda Traffic Rule kugira ngo wige amategeko y\'umuhanda kandi utsinde ikizamini cyawe!';

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
      'Kwakira amamenyesha ya buri munsi';

  @override
  String get settingsLanguage => 'Ururimi';

  @override
  String get settingsAbout => 'Ibyerekeye';

  @override
  String get settingsAboutApp => 'Ibyerekeye Rwanda Traffic Rule';

  @override
  String settingsVersion(Object version) {
    return 'Verisiyo $version';
  }

  @override
  String get settingsPrivacyPolicy => 'Politiki y\'ibanga';

  @override
  String get settingsPrivacyPolicySubtitle => 'Soma politiki yacu y\'ibanga';

  @override
  String get settingsTermsOfService =>
      'Amabwiriza  agenga ikoreshwa rya porogaramu';

  @override
  String get settingsTermsOfServiceSubtitle => 'Soma amabwiriza yacu';

  @override
  String get settingsData => 'Amakuru';

  @override
  String get settingsResetProgress => 'Gusiba iterambere';

  @override
  String get settingsResetProgressSubtitle => 'Siba amakuru yawe yose';

  @override
  String get settingsResetConfirmTitle => 'Gusiba iterambere';

  @override
  String get settingsResetConfirmMessage =>
      'Uzi neza ko ushaka gusiba iterambere ryawe ryose? Iki gikorwa ntigishobora gusubizwaho.';

  @override
  String get settingsResetSuccess => 'Iterambere ryasibwe neza';

  @override
  String get settingsSelectLanguage => 'Hitamo ururimi';

  @override
  String get commonCancel => 'Hagarika';

  @override
  String get commonMenu => 'Menyu';

  @override
  String get commonConfirm => 'Emeza';

  @override
  String get commonReset => 'Subiramo';

  @override
  String get landingHeroTitle => 'Menya amategeko y\'umuhanda byoroshye';

  @override
  String get landingHeroSubtitle =>
      'Witozere ku bibazo byanyabyo kandi utsinde ikizamini cyawe.';

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
  String get landingPracticeExams => 'Ibizamini byo kwitorezaho';

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
  String get authAppName => 'Rwanda Traffic Rule';

  @override
  String get authSubtitle =>
      'Witegure ikizamini cy\'uruhushya rw\'agateganyo rwo gutwara';

  @override
  String get loginTitle => 'Injira kuri konti yawe';

  @override
  String get loginSubtitle =>
      'Andika nimero (wakoresheje wiyandikisha) yawe ya telefoni kugira ngo ukomeze.';

  @override
  String get authNeedHelp => 'Ukeneye ubufasha?';

  @override
  String get loginHelpText => 'Ku bibazo bya konti yawe, hamagara:';

  @override
  String get authPhoneNumber => 'Andika nimero yawe ya telefoni';

  @override
  String get authPhoneHint => '07** *** ***';

  @override
  String get authContinue => 'Emeza';

  @override
  String get loginNoAccount => 'Nta konti ufite? ';

  @override
  String get loginSignUp => 'Iyandikishe';

  @override
  String get authSecureTag => 'Iga • Witegure • Utsinde';

  @override
  String get loginPhoneRequired => 'Nyamuneka andika numero yawe ya telefoni';

  @override
  String get loginInvalidPhone =>
      'Andika numero yawe ya telefoni ikwiye (urugero: 07... cyangwa +250 7...)';

  @override
  String get registerTitle => 'Fungura konti yawe';

  @override
  String get registerSubtitle =>
      'Iyandikishe ukoresheje amazina yawe yombi na nimero yawe ya telefoni kugira ngo utangire kwiga.';

  @override
  String get registerHelpText =>
      'Ku bibazo byo kwiyandikisha cyangwa ibindi bibazo, wahamagara:';

  @override
  String get authFullName => 'Andika Amazina yawe';

  @override
  String get authFullNameHint => 'Andika amazina yawe';

  @override
  String get registerTerms =>
      'Nemeye amabwiriza y\'ikoreshwa n\'amabwiriza y\'ibanga.';

  @override
  String get registerSignUp => 'Emeza';

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
  String get practiceTitle => 'Ibizamini byo kwitorezaho';

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
  String quizScore(Object score) {
    return 'Amanota: $score%';
  }

  @override
  String quizResult(Object correct, Object total) {
    return 'Wasubije neza $correct muri $total';
  }

  @override
  String get quizBackToPractice => 'Kora ikindi kizamini';

  @override
  String get quizNextQuestion => 'Ikibazo gikurikira';

  @override
  String get examMockExam => 'Ibizamini byo kwitorezaho';

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
  String get progressAverageScore => 'Amanota muri muwayene';

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
  String progressMockExam(Object number) {
    return 'Ibizamini byo kwitorezaho $number';
  }

  @override
  String get progressPracticeQuiz => 'Ikizamini cyo kwitozera';

  @override
  String get profileTitle => 'Umwirondoro';

  @override
  String get profileLocation => 'Kigali, Rwanda';

  @override
  String get profileOverallProgress => 'Iterambere rusange';

  @override
  String profileModulesCompleted(Object completed, Object total) {
    return '$completed/$total ibizamini byakozwe';
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
  String get subscriptionTitle => 'Gusaba gufungurirwa imyitozo';

  @override
  String get subscriptionSubtitle => 'saba gufungurirwa imyitozo yose';

  @override
  String get subscriptionTrafficRulesMsg =>
      'Niba ushaka kwiga amategeko y\'umuhanda, wahamagara cyangwa ukatwandikira kuri WhatsApp tukagufasha kwitegura neza ikizamini cy\'uruhushya rw\'agateganyo rwo gutwara ibinyabiziga.';

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
  String subscriptionPrice(Object amount) {
    return '$amount RWF';
  }

  @override
  String get subscriptionRequestAccess => 'Saba uburenganzira';

  @override
  String get subscriptionRequestSent =>
      'Ubusabe bwawe bwoherejwe neza.Tegereza akanya gato bareba ko wishyuye bagufungurire.';

  @override
  String get subscriptionPaymentInstructions => 'Amabwiriza yo kwishyura';

  @override
  String get subscriptionPaymentMomo => 'MoMo Pay: 329494';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788659575';

  @override
  String get subscriptionPaymentTigoCash => 'Tigo Cash: 0728877442';

  @override
  String get subscriptionHelpCall => 'Hamagara: 0788659575';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788659575';

  @override
  String get subscriptionChoosePlan => 'Hitamo gahunda yo kwiga';

  @override
  String get subscriptionCurrency => 'Amezi ushaka kwiga';

  @override
  String get subscriptionAccessActive => 'Uburenganzira burahari';

  @override
  String subscriptionExpires(Object date) {
    return 'Igihe kirangira: $date';
  }

  @override
  String subscriptionDays(Object days) {
    return 'Iminsi $days';
  }

  @override
  String get subscriptionNeedHelp => 'Ukeneye ubufasha?';

  @override
  String subscriptionGetAccess(Object count) {
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
  String adminAccessExpires(Object date) {
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
  String adminRegistrationDate(Object date) {
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
  String get examLocked => 'irafunze';

  @override
  String examQuestions(Object count) {
    return 'Ibibazo $count';
  }

  @override
  String get quizProgress => 'Iterambere';

  @override
  String quizAnswered(Object answered, Object total) {
    return 'Byasubijwe: $answered/$total';
  }

  @override
  String get quizSubmitPractice => 'Soza ikizamini';

  @override
  String get quizPrevious => 'ikibanza';

  @override
  String get quizNext => 'igikurikira';

  @override
  String quizTimeRemaining(Object time) {
    return 'Igihe: $time';
  }

  @override
  String get quizResults => 'Amanota y\'ikizamini';

  @override
  String get quizPassed => 'Watsinze!';

  @override
  String get quizFailed => 'watsizwe';

  @override
  String quizQuestionOf(Object current, Object total) {
    return 'Ikibazo $current kuri $total';
  }

  @override
  String get quizSubmitConfirmTitle => 'Ohereza ikizamini?';

  @override
  String quizSubmitConfirmMessage(Object answered, Object total) {
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
  String profileRegistered(Object date) {
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
  String get paymentMomoPayNumber => 'MoMo Pay: 329494';

  @override
  String get paymentMomoPayDial =>
      'Kwishyura na MoMo Pay, kanda: *182*8*1*329494*amafaranga#';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788659575';

  @override
  String get paymentTigoCashNumber => 'Tigo Cash: 0728877442';

  @override
  String get paymentMobileMoneyDial =>
      'Kwishyura na Mobile Money, kanda: *182*1*1*0788659575*amafaranga#';

  @override
  String get paymentTigoCashDial =>
      'Kwishyura na Tigo Cash, kanda: *182*1*1*0728877442*amafaranga#';

  @override
  String get paymentHelpText =>
      'Ukeneye ubufasha? Hamagara cyangwa WhatsApp: 0788659575';

  @override
  String get paymentHelpContact =>
      'Urashobora kopi cyangwa guhamagara: 0788659575 cyangwa WhatsApp: 0788659575 kugira ubufasha.';

  @override
  String get paymentError =>
      'Ubusabe bwo kwishyura bwananiranye. Nyamuneka wishyure ukoresha amabwiriza hano epfo.';

  @override
  String get paymentCopyNumber => 'Kopi nimero';

  @override
  String get paymentCallNumber => 'Hamagara 0788659575';

  @override
  String get paymentCallTigoNumber => 'Hamagara 0728877442';

  @override
  String get paymentWhatsApp => 'Ohereza ubutumwa kuri WhatsApp';

  @override
  String get paymentWhatsAppMessage =>
      'Saba uburenganzira bwo gukoresha porogaramu y\'ikizamini cy\'uruhushya agateganyo rwo  gutwara ibinyabiziga';

  @override
  String get paymentRequestExists =>
      'Ubusabe bwo kwishyura bwoherejwe. Tegereza akanya gato bagufashe cg uhamagare nimero z\'ubufasha cg wohereze ubutumwa kuri WhatsApp bigaragara hasi kuri paji';

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
      'Mbere yo gusiba konti yawe:\n• Ibisubizo byawe byose bizasibwa burundu\n• Abonement yawe izasibwa\n• Uzakenera kwiyandikisha nanone kugirango ukoreshe porogaramu';

  @override
  String get progressExamsTaken => 'Ibizamini wakozwe';

  @override
  String get progressPassedCount => 'Ibizamini Watsinze';

  @override
  String get progressFailedCount => 'Ibizamini Watsinzwe';

  @override
  String get progressPassRate => 'Ijanisha ryo gutsinda';

  @override
  String get progressNoExams =>
      'Nta bizamini wakozwe. Tangira gukora ibizamini!';

  @override
  String get certificateReadyTitle => 'Witeguye ikizamini cy\'ukuri!';

  @override
  String certificateReadySubtitle(Object count) {
    return 'Warashize $count ibizamini. Witeguye ikizamini cy\'uburenganzira bwo gutwara.';
  }

  @override
  String get certificateIremboLink =>
      'Iyandikishe ku kizamini cya leta kuri irembo.gov.rw';

  @override
  String get certificateIremboDesc =>
      'Kanda hepfo iyandikishe mu kizamini cya mudasobwa cy\'uburenganzira bwo gutwara bw\'igerageza';

  @override
  String certificateExamsNeeded(Object needed) {
    return 'Tsinda ibizamini $needed kugirango ubone icyangombwa cy\'uko witeguye gukora ikizamini cy\'uruhushya rwo gutwara rwagateganyo';
  }

  @override
  String certificateProgressLabel(Object passed, Object total) {
    return '$passed muri $total ibizamini bisabwa';
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
  String get adminBlockUser => 'guhagarika umukoresha';

  @override
  String get adminUnblockUser => 'Fungura Umukoreshwa';

  @override
  String get adminDeleteUserAction => 'Siba Umukoreshwa';

  @override
  String adminBlockUserConfirm(Object name) {
    return 'Urashaka guhagarika $name? arahita atakaza uburenganzira bwo kwinjira.';
  }

  @override
  String adminDeleteUserConfirm(Object name) {
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
      'Ugomba kubanza guhagarika umukoresha mbere yo kumusiba.';

  @override
  String get adminBlockAccess => 'Guhagarika Uburenganzira';

  @override
  String get adminDeleteAccess => 'Gusiba Uburenganzira';

  @override
  String get adminBlockAccessConfirm =>
      'Guhagarika kode y\'uburenganzira? Umukoreshwa azatakaza uburenganzira bwo gukoresha porogaramu.';

  @override
  String get adminDeleteAccessConfirm =>
      'Gusiba kode y\'uburenganzira burundu?';

  @override
  String get adminAccessBlocked => 'Kode y\'uburenganzira yahagaritswe';

  @override
  String get adminAccessDeleted => 'Kode y\'uburenganzira yasibwe';

  @override
  String adminPage(Object page, Object total) {
    return 'Urupapuro $page rwa $total';
  }

  @override
  String get adminLearningLanguage => 'Ururimi rwigwa';

  @override
  String get adminIsBlocked => 'Yahagaritswe';

  @override
  String get adminIsActive => 'Irakora';

  @override
  String get generalCopied => 'Byandukuwe!';

  @override
  String get adminRetry => 'Ongera ugerageze';

  @override
  String get languageSelectDescription =>
      'Ushobora guhindura ururimi nyuma mu igenamiterere.';

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
      'Guhitamo ururimi bituma amakuru, amakarita, n\'amajwi bigaragazwa mu rurimi rwawe. Ushobora guhindura ururimi nyuma mu igenamiterere.';

  @override
  String get commonGotIt => 'Nabyumvise';

  @override
  String get languageSelectDialogTitle => 'Hitamo ururimi';

  @override
  String get examNotFound => 'Ikizamini ntikibonetse';

  @override
  String errorWithDetail(Object detail) {
    return 'Ikosa: $detail';
  }

  @override
  String errorUnexpected(Object detail) {
    return 'Ikosa ridateganijwe: $detail';
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

  @override
  String get examShareResult => 'Sangira Ibisubizo';

  @override
  String get examCopiedToClipboard => 'Ibisubizo byakopeshejwe';

  @override
  String get examGradeLabel => 'Amanota';

  @override
  String get subscriptionPopular => '★ Bukunzwe';

  @override
  String get quizTimeTaken => 'Igihe Nakoresheje';

  @override
  String get progressTotalQuestions => 'Ibibazo';

  @override
  String get progressCorrectAnswers => 'Ibibazo Nakoze';

  @override
  String get progressIncorrect => 'Ibibazo Nishe';

  @override
  String get errorNetwork =>
      'Ntushobora guhuza. Reba interineti yawe ugerageze nanone.';

  @override
  String get paymentChooseMethod => 'Hitamo uburyo bwo kwishyura';

  @override
  String get aboutTitle => 'Ibyerekeye';

  @override
  String get aboutAppName => 'Rwanda Traffic Rule';

  @override
  String get aboutDescription =>
      'Rwanda Traffic Rule ni inshuti yawe yo kwiga amategeko y\'umuhanda mu Rwanda, ibimenyetso by\'umuhanda, no kwitoreza ku ibibazo by\'amategeko kugira ngo witegure ikizamini cy\'uruhushya rwo gutwara rwagateganyo. Iyi ni porogaramu y\'uburezi yigenga kandi ntabwo ifitanye isano n\'ubutegetsi cyangwa ikigo cy\'ibizamini.';

  @override
  String get aboutFeatures => 'Ibintu by\'ingenzi';

  @override
  String get aboutFeaturePractice => 'Ibizamini byo kwitoreza';

  @override
  String get aboutFeatureProgress => 'Kurikirana iterambere';

  @override
  String get aboutFeatureMultilingual => 'Indimi 3';

  @override
  String get aboutFeatureCertificate => 'Impamyabumenyi';

  @override
  String get aboutContact => 'Twandikire';

  @override
  String get aboutContactInfo => 'Tel/WhatsApp: 0788659575 / 0728877442';

  @override
  String get aboutCopyright => 'Uburenganzira bw\'uwakoze porogaramu';

  @override
  String get aboutCopyrightText =>
      '© 2026 Rwanda Traffic Rule. Uburenganzira butangwa n\'uwakoze porogaramu  .';

  @override
  String get privacyLastUpdated => 'Igihe gishya: Werurwe 2026';

  @override
  String get privacyIntro =>
      'Rwanda Traffic Rule yitangiye kurinda ibanga ryawe. Aya mabwiriza asobanura uko dukusanya, dukoresha, kandi turinda amakuru yawe bwite. Turi serivisi y\'uburezi yigenga ntabwo dufitanye isano n\'ubutegetsi.';

  @override
  String get privacyDataCollection => 'Gukusanya amakuru';

  @override
  String get privacyDataCollectionBody =>
      'Dukusanya nimero ya telefoni n\'izina ryawe ryuzuye igihe wiyandikisha. Nanone dukusanya ibisubizo by\'imyitozo n\'amakuru y\'iterambere ryawe. ID y\'igikoresho yihariye ikorwa kugira ngo konti yawe ibe irinzwe.';

  @override
  String get privacyDataUsage => 'Uko dukoresha amakuru yawe';

  @override
  String get privacyDataUsageBody =>
      'Amakuru yawe akoreshwa mu gutanga no kunoza serivisi zacu, gukurikirana iterambere ryawe, gucunga abonement yawe, no kukugezaho amakuru y\'ingenzi.';

  @override
  String get privacyDataProtection => 'Kurinda amakuru';

  @override
  String get privacyDataProtectionBody =>
      'Dukoresha ingamba z\'umutekano z\'urwego rwo hejuru harimo kohereza amakuru mu bwiru no kubika mu buryo bwizewe. Amakuru yawe bwite ntabwo asangizwa  n\'abandi utabyemeje.';

  @override
  String get privacyDataSharing => 'Gusangira amakuru';

  @override
  String get privacyDataSharingBody =>
      'Ntitugurisha amakuru yawe bwite kubandi bantu. Dushobora gusangira amakuru adafite amazina y\'abantu ku mpamvu z\'imibare gusa.';

  @override
  String get privacyUserRights => 'Uburenganzira bwawe';

  @override
  String get privacyUserRightsBody =>
      'Ufite uburenganzira bwo kubona, guhindura, cyangwa gusiba amakuru yawe bwite igihe icyo ari cyo cyose binyuze mu guhitamo Siba Konti mu igenamiterere.';

  @override
  String get termsLastUpdated => 'Igihe gishya: Werurwe 2026';

  @override
  String get termsIntro =>
      'Mu gukoresha Rwanda Traffic Rule, wemeye amabwiriza akurikira. Rwanda Traffic Rule ni porogaramu y\'uburezi yigenga igufasha kwitegura ikizamini cy\'amategeko. Ntabwo dufitanye isano n\'ubutegetsi cyangwa ikigo cy\'ibizamini.';

  @override
  String get termsAcceptance => 'Kwemera amabwiriza';

  @override
  String get termsAcceptanceBody =>
      'Mu gufungura konti no gukoresha iyi porogaramu, wemeye gukurikiza aya mabwiriza. Niba udabyemeye, nyamuneka hagarika gukoresha iyi porogaramu.';

  @override
  String get termsUserAccount => 'Konti y\'umukoresha';

  @override
  String get termsUserAccountBody =>
      'Ni wowe ubifitiye inshingano zo kurinda umutekano wa konti yawe. Buri konti ihuza na nimero imwe ya telefoni n\'igikoresho kimwe. Gusangira amakuru ya konti ntibibujijwe.';

  @override
  String get termsContent => 'Ibiri mu bizamini';

  @override
  String get termsContentBody =>
      'Ibiri mu bizamini byose ni iby\'uburezi n\'imyitozo gusa. Ntabwo bigereranywa n\'ikizamini cy\'ukuri cy\'ubutegetsi. Ntidushobora kwemeza ibisubizo by\'ikizamini. Rwanda Traffic Rule ntabwo ifitanye isano n\'ubutegetsi.';

  @override
  String get termsPayment => 'Gusaba gufungurirwa ibizamini';

  @override
  String get termsPaymentBody =>
      'Uburenganzira bwo gukoresha porogaramu uhamagara ubufasha kuri 0788659575 cyangwa 0728877442.';

  @override
  String get termsTermination => 'Gufunga konti';

  @override
  String get termsTerminationBody =>
      'Dufite uburenganzira bwo guhagarika konti zica aya mabwiriza. Ushobora gusiba konti yawe igihe icyo ari cyo cyose unyeze mu igenamiterere.';

  @override
  String get aboutDisclaimer => 'Icyitonderwa';

  @override
  String get aboutDisclaimerText =>
      'Rwanda Traffic Rule ni porogaramu y\'uburezi yigenga igufasha kwiga amategeko y\'umuhanda no kwitegura ikizamini cy\'amategeko. Iyi porogaramu ntabwo ifitanye isano, yemejwe, cyangwa ihuzwe n\'ubutegetsi cyangwa ikigo cy\'ibizamini. Ibiri muri iyi porogaramu ni iby\'imyitozo n\'uburezi gusa.';

  @override
  String get profileCertificatesTitle => 'Impamyabumenyi';

  @override
  String get profileCertificatesSubtitle =>
      'Impamyabumenyi wabonye n\'iterambere ku ikurikira';

  @override
  String get offlineBanner =>
      'Uri hanze y\'interineti. Amakuru agaragara ashobora kuba atari mashya.';

  @override
  String get syncingData => 'Guhuza amakuru...';

  @override
  String get dataSynced => 'Amakuru yahujwe neza';

  @override
  String get savedOffline =>
      'Byabitswe hanze y\'interineti. Bizahuzwa mugihe usubiye kuri interineti.';

  @override
  String certificateUniqueExamsPassed(Object count, Object total) {
    return '$count kuri $total ibizamini bidasubirwamo byatsinzwe';
  }

  @override
  String certificatePassMark(Object percent, Object required, Object total) {
    return 'Amanota yo gutsinda: $required/$total ($percent%)';
  }

  @override
  String get certificateLatestAttempt => 'Iheruka';

  @override
  String certificateExamStatus(Object index) {
    return 'Ikizamini $index';
  }

  @override
  String get certificateNotAttempted => 'Ibyo utasubije';

  @override
  String get consentTitle => 'Umushakashatsi wawe ni ingenzi';

  @override
  String get consentBody =>
      'Rwanda Traffic Rule ikusanya kandi ikorana n\'amakuru akurikira kugira ngo iguhe uburambe bwiza bwo kwiga:\n\n• Numero ya telefone n\'izina — kugira ngo ufungure konti kandi wemeze\n• Igenzura ry\'igikoresho — igikoresho cyihariye gifashwe na hashi kugira ngo konti yawe irindwe\n• Ibisubizo by\'ibizamini n\'iterambere — kugira ngo dukurikirane urugendo rwawe rwo kwiga\n• Cache ya offline — kugira ngo porogaramu ikore nta interineti\n\nAmakuru yawe abitswe mu buryo bwizewe kandi ntayegurishwa ku bandi. Ushobora gusiba konti yawe n\'amakuru yose ajyanye nayo igihe icyo ari cyo cyose ukoresheje profil yawe.';

  @override
  String get consentAccept => 'Ndabyumva kandi ndabyemeye';

  @override
  String get consentReadPolicy => 'Soma Politiki y\'ubuzima bwite';

  @override
  String get registerInvalidName =>
      'Izina rigomba kuba rigizwe n\'inyuguti n\'umwanya gusa';

  @override
  String get registerInvalidPhone =>
      'Andika numero ya telefone ikwiye (urugero: 078... cyangwa +250 78...)';

  @override
  String get joinGroup => 'WhatsApp Group';

  @override
  String get joinGroupSubtitle => 'Kwinjira mu itsinda rya WhatsApp';

  @override
  String get adminOfflineTooltip =>
      'Nturi kuri interineti – kwerekana amakuru yabitswe';

  @override
  String get adminOfflineBadge => 'NTURI KURI INTERINETI';

  @override
  String adminActiveLabel(Object count) {
    return '$count bakora';
  }

  @override
  String get adminFallbackName => 'Admin';

  @override
  String get adminNoNetworkError => 'Nta mbuga. Nta makuru yabitswe ahari.';

  @override
  String get commonErrorTitle => 'Ikosa';

  @override
  String get exitAppTitle => 'Sohoka muri porogaramu';

  @override
  String get exitAppMessage => 'Uzi neza ko ushaka gusohoka muri porogaramu?';

  @override
  String get exitAppYes => 'Sohoka';

  @override
  String get exitAppNo => 'Guma hano';

  @override
  String get consentItemPhone => 'Nimero ya terefone n\'izina';

  @override
  String get consentItemPhoneDetail => 'Gufungura konti no kwiyerekana';

  @override
  String get consentItemDevice => 'Ikiranga gikoresho';

  @override
  String get consentItemDeviceDetail =>
      'Ikiranga gikoresho gihishe mu rwego rwo kurinda konti yawe';

  @override
  String get consentItemProgress => 'Ibyavuye mu bizamini n\'amajyambere';

  @override
  String get consentItemProgressDetail =>
      'Gukurikirana urugendo rwawe rwo kwiga';

  @override
  String get consentItemCache => 'Ububiko bwa \'Offline\'';

  @override
  String get consentItemCacheDetail =>
      'Porogaramu ikora nta murongo wa interineti';

  @override
  String get consentSecurityNote =>
      'Amakuru yawe abitswe neza kandi ntazigera agurishwa ku bandi.';

  @override
  String get consentIndependentTitle => 'Ibirimo byigenga';

  @override
  String get consentIndependentBody =>
      'Iyi ni porogaramu y\'uburezi yigenga. Ntabwo yunganirwa, ishyigikirwa cyangwa ihagarariye urwego rwa leta cyangwa Polisi y\'u Rwanda.';

  @override
  String get dashboardWelcome => 'Murakaza neza';

  @override
  String get dashboardNotices => 'AMABWIRIZA';

  @override
  String get dashboardWhatsapp => 'WhatsApp Group';

  @override
  String get dashboardGazette => 'IGAZETI NSHYA';

  @override
  String get dashboardShare => 'Sangiza App';

  @override
  String get dashboardProfileUnavailable => 'Amakuru ya konti ntaboneka';

  @override
  String get dashboardLoading => 'Turimo gushaka amakuru y’uburenganzira…';

  @override
  String get dashboardSubscriptionUnavailable =>
      'Amakuru y’uburenganzira ntaboneka. Manura urupapuro wongere ugerageze.';

  @override
  String get dashboardExpired => 'Uburenganzira bwo kwiga bwararangiye';

  @override
  String get dashboardDurationUnavailable => 'Ntibizwi';

  @override
  String dashboardDuration(Object duration) {
    return 'Igihe: $duration';
  }

  @override
  String get dashboardCached =>
      'Amakuru yabitswe · manura urupapuro uyavugurure';

  @override
  String get dashboardNoticesUnavailable =>
      'Amabwiriza ntaboneka ubu. Ongera ugerageze nyuma.';

  @override
  String get dashboardNoNotices => 'Nta mabwiriza arahari';

  @override
  String get dashboardCopyLink => 'Koporora ihuza';

  @override
  String get dashboardLinkCopied => 'Ihuza ryakoporowe';

  @override
  String get dashboardOpenFailed => 'Ntibishobotse. Ongera ugerageze.';

  @override
  String get dashboardComingSoon => 'Biraza vuba';

  @override
  String get dashboardUnderDevelopment => 'Iyi serivisi iracyatunganywa.';

  @override
  String get dashboardExamsLocked => 'Ibizamini ntibifunguye';

  @override
  String get dashboardRequestExamAccess =>
      'Kanda hano usabe ko ibizamini bifunguka';

  @override
  String get paymentExamLanguage => 'Ururimi rw’ibizamini';

  @override
  String get paymentExamLanguageHint =>
      'Hitamo ururimi rw’ibizamini. Ibi ntibihindura ururimi rwa porogaramu.';

  @override
  String paymentAmountToPay(Object amount) {
    return 'Amafaranga yo kwishyura: $amount RWF';
  }

  @override
  String get paymentMethodLabel => 'Uburyo bwo kwishyura';

  @override
  String get paymentNotConfigured => 'Amakuru yo kwishyura ntarashyirwaho.';

  @override
  String get paymentUssdLabel => 'Kode USSD yo kwishyura';

  @override
  String get paymentCopyCode => 'Koporora kode';

  @override
  String get paymentCodeCopied => 'Kode yakoporowe';

  @override
  String get paymentCopyFailed =>
      'Kode ntiyakoporowe. Ongera ugerageze cyangwa uyikoporore ubwawe.';

  @override
  String get paymentUssdInstruction =>
      'Koporora iyi kode uyikoreshe kuri telefoni yawe kugira ngo wishyure.';

  @override
  String get paymentPayNow => 'Kanda hano wishyure';

  @override
  String get paymentIntegrationPending =>
      'Amakuru yo kwishyura yateguwe. Uburyo bwo gutangiza ubwishyu ntiburahuzwa; nta bwishyu bwemejwe.';

  @override
  String get paymentPreparationFailed =>
      'Ntibishobotse gutegura ubwishyu. Ongera ugerageze.';

  @override
  String paymentRecipient(Object method, Object name) {
    return '$method ibaruye kuri: $name';
  }

  @override
  String get paymentVerifyRecipient =>
      'Genzura ko MoMo pay ibaruye kuri ALEXIS nugira ikibazo uduhamagare kuri 0788659575 cga 0728877442';

  @override
  String get dashboardGazetteSubtitle => 'Amategeko y\'umuhanda';

  @override
  String get dashboardIremboSubtitle => 'Serivisi z’irembo';

  @override
  String get guideTitle => 'AMABWIRIZA';

  @override
  String get guideWelcome => 'Ikaze kuri RWANDA TRAFFIC RULE';

  @override
  String get guideAboutTitle => '1. Ubusobanuro bw\'application';

  @override
  String get guideAboutBody =>
      'Iyi application yitwa ``RWANDA TRAFFIC RULE`` ni application yigisha amategeko y\'umuhanda, igizwe n\'ibibazo babaza mu kizamini cya provisoire (uruhushya rw\'agatenyo)';

  @override
  String get guideUseTitle => '2. UKO APPLICATION IKORA';

  @override
  String get guideUseBody =>
      '1. Kugirango ukoresheiyi application ugomba kubanza kwiyandikisha kuri application mugihe ukoze download bwa mbere aho usabwa kwandika amazina yawe, nimero yawe telephone; warangiza ugakanda ahanditse EMEZA\n\n2. Mugihe usanzwe wariyandikishe ntabwo wongera kwiyandisha ahubwo ukanda ahanditse \"INJIRA\" ubundi ugashyiramo nimero ya telephone  ubundi ugakanda \"EMEZA\" ugahita ugera ahitwa dashboard usanga ibikubyemo muri application.\n\n3. Gutangira kwiga ukanda ahanditse \"IMYITOZO\" iyo uhafunguye hagizwe y\'ibizamini 21 buri mwitozo ugizwe n\'ibibazo 20, ariko umwitozo wa mbere ni ubuntu (free) indi isigaye bisaba kwishyura.\n\n4. Iyo uri kwitoza muri iyi application ukanda mu kazu iyo ugikoze gihinduka icyatsi naho iyo ucyishe gihinduka umutuku kuko ari ukwitoza uhita ubona igisubizo cyukuri ako kanya uhita ugerageza kugifata cga kumenya (kukiboroka) warangiza ugakanda abanditse \"igikurikira\" ukajya kukindi kibazo iyo ugeze kucyanyuma ukanda ahanditse \"soza ikizamini\" ugahita ubona n\'amanota ugize ugahita  ajya guhitamo ikindi kizamini wiga';

  @override
  String get guideExamTitle =>
      '3. UKO UZASANGA IBIBAZO BIMEZE  KURI EXAM YA PROVISOIRE  NYIRIZINA';

  @override
  String get guideExamBody =>
      'A. Nugera muri exam ya provisoire kuri machine Bwa mbere bazabanza bakwitegereze (bagupime) ko udafite ubumuga, ubona, wumva, uzi gusoma no kwandika, ufite indangamuntu y\'umwimerere cga indangampunzi (impunzi) na code y\'uwo munsi, ibindi byinshi,... urugero ikinyabupfura, ku utari  umusinzi,...\n\nB. Uzasanga ibi bibazo biri muri iyo application ari nako bimeze muri exam nta kibazo bazakubaza muri exam ya provisoire kitari muri iyi application, Muguhitamo igisubizo uzakanda MUKAVI ugakomeza kukindi kibazo  ukanze ahanditse IGIKURIKIRA ukomeze n\'ibindi bibazo iyo ubirangije uzakanda ahanditse ``SOZA IKIZAMINI`` uzahita umenya amanota ugize Ako kanya ndetse ushatse wanagenzura ibyo wishe ndetse nibyo wakoze.\n\nC. Aho bitaniye no muri exam ya provoire kuri machine nuko hano iyo ucyishe cga ugikoze uhita umenya  igisubizo cy\'ukuri ako kanya  naho kuri exam nyirizina udahita umenya igisubizo.\n\nD. Hejuru hari imibare kuva kuri 1 kugeza 20 igaragaza ibibazo wasimbutse, ibyo umaze gusubiza nibyo usigaje gukora\n\nE. Amanota yo gutsindiraho muri exam ya ni 12/20 angana na 60% naho hano muri application yacu (nge umunyeshuri wiga amategeko yumuhanda, n\'abayikoze ndetse n\'abayikoramo,..) amanota yo gutsinda ni 80% angana 16/20 muri application ahanditse \"iterambere\" hagaragaza uko ibi bibazo ubyiga uko ubitsinda ariko amanota yibikayo iyo uri kwiga ufite interineti nubwo kwiga atari ngombwa interineti mu gihe wafunze connection wakiga ahanditse amanota muri rusange ntabwo yiyongera';

  @override
  String get guidePaymentTitle =>
      '4. KWISHYURA KUGIRA NGO IBIZAMINI BYOSE BIFUNGUKE';

  @override
  String get guidePaymentBody =>
      '1. Nk\'uko nabisobanuye bwa mbere umwitozo  ya mbere ni ubuntu indi 20 bisaba kwishyura 1500Rwf kwiga ukwezi kumwe, 3000Rwf kwiga amezi atatu cyangwa 5000 Rwf kwiga amezi atandatu kuri 0788659575/ 0728877442 cg kuri MOMO PAY: 329494 ibaruye kuri Alexis.\n\nKwishyura wakoresha nimero ushaka bitemewe si ngomba ikubaruyeho ariko mu gihe  ukoresheje indi nimero iyo umaze kwishyura uhita uduhamagara\n\nA. Kwishyura ukoresheje MTN ukanda:\na. *182*1*1*0788659575*1500#\nb. *182*8*1*329494*1500#\n\nB. Kwishyura ukoresheje Tigo cga Airtel\na. *500*1*1*0728877442*1500#\nb. *182*8*1*88329494*1500#\nIbaruye kuri ALEXIS\n\n2. Iyo umaze kwishyura uhite ureba niba ufite connection (internet) ugategereza iminota  ibiri ugahita ukanda imbere y\'ahanditse ururimi ku ka↪️ ugahita ufungura imyitozo usanga byafungutse utugufuri twavuyeho twose.\n\n4. IBINDI BISABANURO BIRAMBUYE WADUHAMAGARA:';

  @override
  String get guideOpenAccess => 'Reba ibiciro wishyure';

  @override
  String get dashboardRefresh => 'Ongera ugenzure uburenganzira';

  @override
  String get dashboardRefreshDone => 'Uburenganzira bwongeye kugenzurwa.';

  @override
  String get dashboardRefreshFailed =>
      'Ntibyashobotse kugenzura uburenganzira. Reba interineti wongere ugerageze.';

  @override
  String get resourcesTitle => 'Inyandiko';

  @override
  String get resourcesDescription =>
      'Soma dikenalizi n’ibyapa muri application. Izi dikenalizi zirimo kandi zisomwa nta interneti; zigumana ururimi zanditswemo.';

  @override
  String get resourcesGazette => 'Ikigazeti';

  @override
  String get resourcesRoadSigns => 'Ibyapa';

  @override
  String get resourcesOfflinePdf => 'PDF • Soma nta interneti';

  @override
  String get resourcesReadError =>
      'Ntibyashoboye gukoresha iyi dikenalizi.ongere ukongere.';

  @override
  String get resourcesPreviousPage => 'Urupapuro rubanza';

  @override
  String get resourcesNextPage => 'Urupapuro rukurikira';

  @override
  String get resourcesZoomOut => 'Gabanya';

  @override
  String get resourcesZoomIn => 'Ongera ubunini';

  @override
  String get resourcesLoading => 'Inyandiko irimo guhinduka…';

  @override
  String resourcesPageCount(Object page, Object total) {
    return 'Urupapuro $page kuri $total';
  }

  @override
  String get irTitle => 'Serivisi z’irembo';

  @override
  String get irAlreadySubmitted => 'Ubusabe yarakoze yerekwa';

  @override
  String get permisOption => 'Igice cy’irembo';

  @override
  String get irOption => 'Igice cy’irembo';

  @override
  String get irServiceFee => 'Amafaranga yo kwiyandikisha ubusabe';

  @override
  String get irPay => 'Ishyura';

  @override
  String get irWorkspace => 'Ubuzima bw’irembo';

  @override
  String get irMyRequests => 'Ubusabe bwanajye';

  @override
  String get irNew => 'Ubusabe bushya';

  @override
  String get irManual => 'Manuweli';

  @override
  String get irAutomatic => 'Otomatike';

  @override
  String get irNotice =>
      'Iyo umaze kwishyura bihita bikunda ukabona code ukeneye';

  @override
  String get irFullName => 'Amazina yose';

  @override
  String get irPhone => 'Nimero ya telefoni';

  @override
  String get irNationalId => 'Nimero y’indangamuntu';

  @override
  String get irDob => 'Itariki y’amavuko';

  @override
  String get irExamLanguage => 'Ururimi rw’ikizamini';

  @override
  String get irLanguageHint => 'Urugero: Ikinyarwanda, Icyongereza, Igifaransa';

  @override
  String get irDistrict => 'Akarere wifuza gukorwa ikizamini';

  @override
  String get irExamDate => 'Itariki yifuzwa (si ngombwa)';

  @override
  String get irDateNotice => 'Itariki yifuzwa si inzira y’ikizamini.';

  @override
  String get irProvisoireCode => 'Code ya provisoire';

  @override
  String get irCategory => 'Icyiciro cy’uruhushya';

  @override
  String get irService => 'Serivisi';

  @override
  String get irSelectRequest => 'Hitamo ubu bureau';

  @override
  String get irReview => 'Genzura ubusabe';

  @override
  String get irConfirm => 'Ohereza ubusabe';

  @override
  String get irEdit => 'Hindura ubusabe';

  @override
  String get irSaved => 'Ubusabe bwakiye';

  @override
  String get irReference => 'Inomero y’ubusabe';

  @override
  String get irStatus => 'Uko buhagaze';

  @override
  String get irSubmitted => 'Igihe bwoherejwe';

  @override
  String get irUpdated => 'Igihe buherirwa';

  @override
  String get irAssigned => 'Umukozi ubishinzwe';

  @override
  String get irUnassigned => 'Nta mukozi wabugenewe';

  @override
  String get irPending => 'Bibura burekana';

  @override
  String get irInReview => 'Burimo gusuzumwa';

  @override
  String get irNeedsInformation => 'Hari amakuru adakwiye';

  @override
  String get irCompleted => 'Byarongereye';

  @override
  String get irRejected => 'Byarongwa';

  @override
  String get irCancelled => 'Byangiritse';

  @override
  String get irSearch => 'Shakisha izina, telefoni cyangwa indangamuntu';

  @override
  String get irFilters => 'Ibyo ushunguriraho';

  @override
  String get irApply => 'Shungurira';

  @override
  String get irClear => 'Kuraho ibyo ushunguriraho';

  @override
  String get irAll => 'Byose';

  @override
  String get irFrom => 'Bwoherejwe kuva';

  @override
  String get irTo => 'Bwoherejwe kugeza';

  @override
  String get irNewest => 'Ubushya mbere';

  @override
  String get irOldest => 'Ubwa kera mbere';

  @override
  String get irSort => 'Tondeka ukurikije';

  @override
  String get irEmpty => 'Nta busabe buhuye';

  @override
  String get irView => 'Reba amakuru';

  @override
  String get irCall => 'Hamagara uwasabye';

  @override
  String get irCopy => 'Copora';

  @override
  String get irCopyAll => 'Copora amakuru y’uwasabye';

  @override
  String get irCopied => 'Byakoporohejwe';

  @override
  String get irCopyFailed => 'Gukopora byanze. Ongera ugerageze.';

  @override
  String get irCallFailed => 'Porogaramu yo gusimbuza itari ufungutse.';

  @override
  String get irMessages => 'Ubutumwa bugenewe uwasabye';

  @override
  String get irInternalNotes => 'Inyandiko z’abakozi gusa';

  @override
  String get irInternalHint => 'Bigaragara abakozi gusa';

  @override
  String get irMessage => 'Ubutumwa bwoherejwe uwasabye';

  @override
  String get irReason => 'Impamvu (igaragaza uwasabye)';

  @override
  String get irReasonRequired => 'Tanga impamvu y’uko ubusabe buhagaze.';

  @override
  String get irAudit => 'Amateka y’impinduka';

  @override
  String get irSave => 'Bika impinduka';

  @override
  String get irRetry => 'Ongera ugerageze';

  @override
  String get irClose => 'Funga';

  @override
  String get irRequired => 'Aya makuru ni ngombwa.';

  @override
  String get irInvalid => 'Genzura amakuru wanditse.';

  @override
  String get irInvalidId => 'Andika imibare 16 gusa.';

  @override
  String get irInvalidPhone =>
      'Andika nimero ya telefoni igendanwa yemewe mu Rwanda.';

  @override
  String get irUnavailable =>
      'Ntibyashoboya kugera kuri iyi serivisi. genzura interineti wongere ugerageze. amakuru wanditse erdasohora.';

  @override
  String get irConflict =>
      'Ubu busabe bwarahinduwe cyangwa bwaroherejwe. vugurura urutonde mbere yo gukora igisubizo.';

  @override
  String get irNext => 'Ibikurikira';

  @override
  String get irPrevious => 'Ibibangira';

  @override
  String get irCreated => 'Ubusabe bwakozwe';

  @override
  String get irChange => 'Impinduka';

  @override
  String get irNoMessages => 'Nta butumwa burahagera.';

  @override
  String get irResults => 'Ibyaboneye';

  @override
  String get irSelectDistrict => 'Shakisha ihitemo akarere';

  @override
  String get irEnglish => 'Icyongereza';

  @override
  String get irFrench => 'Igifaransa';

  @override
  String get irKinyarwanda => 'Ikinyarwanda';

  @override
  String get irChooseService => 'Hitamo serivisi y’ikizamini';

  @override
  String get irChooseOption => 'Hitamo ubwoko bwa permis';

  @override
  String get irProvisoireHelp => 'Ikizamini cy’uruhushya rw’agateganyo';

  @override
  String get irPermisHelp => 'Ikizamini cy’uruhushya rw’uruhushya';

  @override
  String get irContinue => 'Iyandikishe';

  @override
  String get irRequestsUnavailable => 'Ubusabe bwawe ntibwashoboka kuboneka.';

  @override
  String get irServerSetup =>
      'Ubusabe bwo kwiyandikisha ntibikoreshwa hejuru gusa fasha abafasha cyangwa ugere kandi wongere.';

  @override
  String get irServiceUnavailable =>
      'Ubusabe bwo kwiyandikisha butaragaragara. ongera ugerageze.';

  @override
  String get irAccessUnavailable =>
      'Ntiwemewe kureba ubu bureau. genzura konti wiyandikishije.';

  @override
  String get irNoRequests => 'Hitamo serivisi urangire.';

  @override
  String get irStaffHelp =>
      'Shakisha abasabye, suzuma ubusabe kandi ukuzimira ubufasha bwo kwiyandikisha.';

  @override
  String get waIntro =>
      'Twitegure hamwe. hitamo itsinda ubazamo ibibazo kandi musangire inama zo kwiga.';

  @override
  String get waManageIntro =>
      'Cunga amatsinda yo kwigiramo ahabwa abanyeshuri.';

  @override
  String get waCached =>
      'Aya ni amatsinda yabitswe. kwinjira mu itsinda cyangwa kwakira ubutumwa bushya bisaba interineti.';

  @override
  String get progressSaved =>
      'Aya ni amanota yabitswe kuri iki gikoresho. amashya azoherezwa igihe interineti ibonye.';

  @override
  String get irDeleteRequest => 'Siba ubusabe';

  @override
  String get irDeleteConfirm =>
      'Gusiba burundu ubu busabe n’ubutumwa bwabwo? Ntibishobora gusubizwa.';

  @override
  String get irSelectPage => 'Hitamo ubu bureau bwose kuri iyi paji';

  @override
  String get irSelected => 'Byatoranyijwe';

  @override
  String get irDeleteSelected => 'Siba ibyatoranyijwe';

  @override
  String get irOfflineSaved =>
      'Ubu ni ubusabe bwabitswe. huzwa interineti kugira ngo uvugurure, wohereze cyangwa usibe ubusabe.';

  @override
  String get irDeleteUnavailable =>
      'Gusiba ntibiraboneka kuri seriveri. Vugurura inzira za API n’igice gishinzwe ubusabe bwa Irembo kuri seriveri, hanyuma wongere ugerageze.';

  @override
  String get referralTitle => 'Tumira abandi';

  @override
  String get referralHeading => 'Twitegure neza, turi kumwe.';

  @override
  String get referralDescription =>
      'Fasha inshuti kwitegura ikizamini cy’amategeko y’umuhanda. Sangiza ubutumire bwawe maze ukurikirane abiyandikishije hano.';

  @override
  String get referralSubtitle => 'Tumira inshuti. Kurikirana ubutumire bwawe.';

  @override
  String get referralYourCode => 'Kode yawe y’ubutumire';

  @override
  String referralCodeLabel(Object code) {
    return 'Kode: $code';
  }

  @override
  String get referralInvite => 'Tumira inshuti';

  @override
  String get referralCopy => 'Koporora ihuza ry’ubutumire';

  @override
  String get referralHistory => 'Amateka y’ubutumire';

  @override
  String get referralTotal => 'Abatumirwa bose';

  @override
  String get referralConfirmed => 'Kwiyandikisha byemejwe';

  @override
  String get referralPending => 'Birategereje';

  @override
  String get referralRewardsDisabled =>
      'Gukurikirana ubutumire birakora. Ibihembo ntibirashyirwaho, bityo ubutumire ntibutanga amafaranga cyangwa uburenganzira bwo gukorana imyitozo ubu.';

  @override
  String get referralEmpty =>
      'Ubutumire bwawe buzagaragara hano inshuti zimaze gufungura konti zikoresheje ihuza ryawe.';

  @override
  String get referralLoadError =>
      'Ntitwashoboye kubona ubutumire bwawe. Reba interineti maze wongere ugerageze.';

  @override
  String get referralInviteMessage =>
      'Itegure ikizamini cy’amategeko y’umuhanda mu Rwanda ukoresheje Rwanda Traffic Rules! Kuramo porogaramu maze utangire kwiga ukoresheje ubutumire bwanjye:';

  @override
  String get referralShareUnavailable =>
      'Gusangiza ntibishoboka hano. Koporora ihuza ry’ubutumire maze uryohereze.';

  @override
  String get referralMore => 'Erekana ibindi';

  @override
  String get adminReferrals => 'Ubutumire';

  @override
  String get adminReferralSearch =>
      'Shakisha izina, kode y’ubutumire cyangwa telefoni';

  @override
  String get adminReferralInvitees => 'Abatumiwe';

  @override
  String get adminReferralDeletedUser => 'Konti yasibwe';

  @override
  String get dashboardReferrals => 'Tumira inshuti';

  @override
  String get authRecoverTitle => 'Garuka kuri konti kuri iki gikoresho';

  @override
  String get authRecoverBody =>
      'Konti yawe iri ku kindi gikoresho. Andika amazina yawe yombi kugira ngo uzane iyi konti kuri iyi telefoni.';

  @override
  String get authRecoverNameLabel => 'Amazina yombi';

  @override
  String get authRecoverConfirm => 'Garuka kuri konti';

  @override
  String get authRecoverNameRequired =>
      'Andika amazina yawe yombi kugira ngo ugaruke kuri iyi konti.';

  @override
  String get authMoveTitle => 'Zana konti kuri iki gikoresho';

  @override
  String get authMoveBody =>
      'Iyi nimero ya telefoni isanzweho ku kindi gikoresho. Ushaka kuzana iyi konti kuri iyi telefoni?';

  @override
  String get authMoveConfirm => 'Zana konti';

  @override
  String get authMoveDetailsRequired =>
      'Andika amazina yawe yombi na nimero ya telefoni kugira ngo ugaruke kuri iyi konti.';

  @override
  String get languageConfirmLabel => 'Emeza ururimi';

  @override
  String get profileUserNotFound => 'Umukoresha ntabonetse';

  @override
  String get profileUserLoadFailed => 'Ntibyashobotse kubona umukoresha';

  @override
  String get referralNotAuthenticated => 'Ntabwo wiyandikishije';

  @override
  String get waLoadError =>
      'Ntibishobotse kubona amatsinda ya WhatsApp. Reba ko ufite interineti wongere ugerageze.';

  @override
  String get waAddTitle => 'Ongeramo itsinda rya WhatsApp';

  @override
  String get waEditTitle => 'Hindura itsinda rya WhatsApp';

  @override
  String get waGroupName => 'Izina ry’itsinda';

  @override
  String get waNameRequired => 'Andika izina';

  @override
  String get waInviteLink => 'Ihuza ryo kwinjira muri WhatsApp';

  @override
  String get waInviteLinkInvalid => 'Andika ihuza rya WhatsApp rikwiye';

  @override
  String get waCancel => 'Reka';

  @override
  String get waSave => 'Bika';

  @override
  String get waSaveError => 'Ntibishobotse kubika itsinda';

  @override
  String get waDeleteTitle => 'Siba itsinda?';

  @override
  String get waDelete => 'Siba';

  @override
  String get waDeleteError => 'Ntibishobotse gusiba itsinda';

  @override
  String get waEmpty => 'Nta matsinda ya WhatsApp arahari.';

  @override
  String get waOpenError => 'Ntibishobotse gufungura itsinda';

  @override
  String get waEditTooltip => 'Hindura';
}
