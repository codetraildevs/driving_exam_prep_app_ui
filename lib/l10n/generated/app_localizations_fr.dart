// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Rwanda Traffic Rule';

  @override
  String get languageSelectTitle => 'Choisissez votre langue';

  @override
  String get languageSelectSubtitle =>
      'Vous pouvez changer cela plus tard dans les Paramètres';

  @override
  String get languageSelectConfirm => 'Continuer';

  @override
  String get homeWelcomeBack => 'Bon retour 👋';

  @override
  String homeGreeting(String userName) {
    return '$userName';
  }

  @override
  String get homeContinueMessage =>
      'Continuez à maîtriser le code de la route aujourd\'hui.';

  @override
  String get homeContinueLearning => 'Continuer à apprendre';

  @override
  String homeAccessActive(int daysLeft) {
    return 'Accès actif - $daysLeft jours restants';
  }

  @override
  String homePaymentTier(String tier) {
    return 'Forfait : $tier';
  }

  @override
  String homePracticeSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions d\'entraînement',
      one: '1 session d\'entraînement',
      zero: 'Aucune session d\'entraînement',
    );
    return '$_temp0';
  }

  @override
  String get homePractices => 'Exercices';

  @override
  String get homePracticesSubtitle => 'Questions pratiques';

  @override
  String get homeCourses => 'Cours';

  @override
  String get homeCoursesSubtitle => 'Modules d\'apprentissage';

  @override
  String get homeMockExams => 'Examens blancs';

  @override
  String get homeMockExamsSubtitle => 'Tester les connaissances';

  @override
  String get homeProgress => 'Progrès';

  @override
  String get homeProgressSubtitle => 'Suivre la performance';

  @override
  String get homeShareApp => 'Partager l\'appli';

  @override
  String get homeShareAppSubtitle => 'Inviter des amis';

  @override
  String get homeShareAppMessage =>
      'Téléchargez Rwanda Traffic Rule pour apprendre le code de la route et réussir votre examen !';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsDarkModeSubtitle => 'Utiliser le thème sombre';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Recevoir des rappels quotidiens';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutApp => 'À propos de Rwanda Traffic Rule';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Lire notre politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsTermsOfServiceSubtitle => 'Lire nos conditions';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsResetProgress => 'Réinitialiser la progression';

  @override
  String get settingsResetProgressSubtitle => 'Effacer toutes vos données';

  @override
  String get settingsResetConfirmTitle => 'Réinitialiser la progression';

  @override
  String get settingsResetConfirmMessage =>
      'Êtes-vous sûr de vouloir réinitialiser toute votre progression ? Cette action est irréversible.';

  @override
  String get settingsResetSuccess => 'Progression réinitialisée avec succès';

  @override
  String get settingsSelectLanguage => 'Choisir la langue';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonMenu => 'Menu';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get landingHeroTitle => 'Maîtrisez le code de la route facilement';

  @override
  String get landingHeroSubtitle =>
      'Entraînez-vous avec de vraies questions et réussissez votre permis.';

  @override
  String get landingGetStarted => 'Commencer';

  @override
  String get landingAlreadyHaveAccount =>
      'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get landingWhyUseApp => 'Pourquoi utiliser notre application ?';

  @override
  String get landingLearnRules => 'Apprendre les règles';

  @override
  String get landingLearnRulesDesc =>
      'Explications claires de toutes les lois de la circulation et des panneaux de signalisation.';

  @override
  String get landingPracticeExams => 'Examens pratiques';

  @override
  String get landingPracticeExamsDesc =>
      'Passez des examens blancs similaires au vrai test de conduite.';

  @override
  String get landingTrackProgress => 'Suivre les progrès';

  @override
  String get landingTrackProgressDesc =>
      'Surveillez vos performances et améliorez vos points faibles.';

  @override
  String get landingHowItWorks => 'Comment ça marche';

  @override
  String get landingStep1 => 'Créez votre compte gratuit';

  @override
  String get landingStep2 => 'Commencez à apprendre le code de la route';

  @override
  String get landingStep3 => 'Passez des examens blancs';

  @override
  String get landingStep4 => 'Réussissez votre vrai examen en toute confiance';

  @override
  String get landingReadyTitle => 'Prêt à réussir votre examen de conduite ?';

  @override
  String get landingStartLearning => 'Commencer à apprendre';

  @override
  String get homeServices => 'Services';

  @override
  String get authAppName => 'Rwanda Traffic Rule';

  @override
  String get authSubtitle => 'Préparez le permis de conduire provisoire';

  @override
  String get loginTitle => 'Connectez-vous à votre compte';

  @override
  String get loginSubtitle =>
      'Entrez votre numéro de téléphone enregistré pour continuer.';

  @override
  String get authNeedHelp => 'Besoin d\'aide ?';

  @override
  String get loginHelpText =>
      'Pour les problèmes de compte ou les questions, contactez :';

  @override
  String get authPhoneNumber => 'Numéro de téléphone';

  @override
  String get authPhoneHint => '07** *** ***';

  @override
  String get authContinue => 'Continuer';

  @override
  String get loginNoAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get loginSignUp => 'S\'inscrire';

  @override
  String get authSecureTag => 'Sécurisé • Rapide • Pass';

  @override
  String get loginPhoneRequired => 'Veuillez entrer votre numéro de téléphone';

  @override
  String get loginInvalidPhone =>
      'Entrez un numéro de téléphone valide (ex: 078... ou +250 78...)';

  @override
  String get registerTitle => 'Créez votre compte';

  @override
  String get registerSubtitle =>
      'Inscrivez-vous avec votre nom complet et numéro de téléphone pour commencer à apprendre.';

  @override
  String get registerHelpText =>
      'Pour les problèmes d\'inscription ou les questions, contactez :';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authFullNameHint => 'Entrez votre nom complet';

  @override
  String get registerTerms =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité.';

  @override
  String get registerSignUp => 'S\'inscrire';

  @override
  String get registerHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get registerLogIn => 'Se connecter';

  @override
  String get registerFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get registerAgreeTerms => 'Veuillez accepter les conditions générales';

  @override
  String get forgotPasswordTitle =>
      'Réinitialisation du mot de passe non disponible';

  @override
  String get forgotPasswordDescription =>
      'Ce backend utilise le numéro de téléphone et la liaison d\'appareil (pas de flux de réinitialisation de mot de passe).';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPractice => 'Pratique';

  @override
  String get navProgress => 'Progrès';

  @override
  String get navProfile => 'Profil';

  @override
  String get practiceTitle => 'Quiz pratique';

  @override
  String get practiceCategorySpeedLimits => 'Limites de vitesse';

  @override
  String get practiceCategoryRoadSigns => 'Panneaux routiers';

  @override
  String get practiceCategoryLaneControl => 'Gestion des voies';

  @override
  String get practiceCategoryParkingRules => 'Règles de stationnement';

  @override
  String get practiceStart => 'Commencer →';

  @override
  String get quizComplete => 'Quiz terminé !';

  @override
  String quizScore(int score) {
    return 'Score : $score%';
  }

  @override
  String quizResult(int correct, int total) {
    return 'Vous avez obtenu $correct sur $total correctes';
  }

  @override
  String get quizBackToPractice => 'Retour à la pratique';

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String get quizFinish => 'Terminer le quiz';

  @override
  String get quizNextQuestion => 'Question suivante';

  @override
  String get examMockExam => 'Examen blanc';

  @override
  String get examInstructions => 'Instructions de l\'examen';

  @override
  String get examTimeLimit => 'Limite de temps';

  @override
  String get examTimeLimitDesc => '30 minutes au total pour 20 questions';

  @override
  String get examQuestionCount => '20 Questions';

  @override
  String get examQuestionCountDesc =>
      'Format à choix multiples avec 4 options chacune';

  @override
  String get examPassingScore => 'Score de réussite';

  @override
  String get examPassingScoreDesc =>
      'Vous devez obtenir 70% ou plus pour réussir';

  @override
  String get examNoGoingBack => 'Pas de retour en arrière';

  @override
  String get examNoGoingBackDesc =>
      'Vous ne pouvez pas revenir aux questions précédentes';

  @override
  String get examWarning =>
      'Assurez-vous d\'avoir une connexion internet stable et de ne pas être interrompu';

  @override
  String get examStartExam => 'Commencer l\'examen';

  @override
  String get examSubmit => 'Soumettre l\'examen';

  @override
  String get examCongratulations => 'Félicitations !';

  @override
  String get examGoodEffort => 'Bon effort';

  @override
  String get examPassedMessage => 'Vous avez réussi l\'examen haut la main !';

  @override
  String get examFailedMessage =>
      'Continuez à pratiquer pour améliorer votre score';

  @override
  String get examYourScore => 'Votre score';

  @override
  String get examCorrect => 'Correct';

  @override
  String get examAccuracy => 'Précision';

  @override
  String get examNeedMorePractice =>
      'Vous devez obtenir 70% pour réussir. Pratiquez davantage !';

  @override
  String get examBadgeEarned =>
      'Vous avez obtenu un badge pour avoir réussi l\'examen !';

  @override
  String get examRetakeTest => 'Repasser le test';

  @override
  String get examBackHome => 'Retour à l\'accueil';

  @override
  String get progressTitle => 'Vos progrès';

  @override
  String get progressPerformanceSummary => 'Résumé des performances';

  @override
  String get progressTotalAttempts => 'Tentatives totales';

  @override
  String get progressBestScore => 'Meilleur score';

  @override
  String get progressAverageScore => 'Score moyen';

  @override
  String get progressSignsLearned => 'Panneaux appris';

  @override
  String get progressRecentExams => 'Examens récents';

  @override
  String get progressOverall => 'Progression globale';

  @override
  String get progressComplete => 'Terminé';

  @override
  String get progressAvgScore => 'Score moy.';

  @override
  String get progressSigns => 'Panneaux';

  @override
  String get progressPassed => 'Réussi';

  @override
  String get progressExcellent => 'Excellent';

  @override
  String progressMockExam(int number) {
    return 'Examen blanc $number';
  }

  @override
  String get progressPracticeQuiz => 'Quiz pratique';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileLocation => 'Kigali, Rwanda';

  @override
  String get profileOverallProgress => 'Progression globale d\'apprentissage';

  @override
  String profileModulesCompleted(int completed, int total) {
    return '$completed/$total Modules terminés';
  }

  @override
  String get profileAccount => 'Compte';

  @override
  String get profileSettings => 'Paramètres';

  @override
  String get profileSettingsSubtitle =>
      'Notifications, langue, confidentialité';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileDeleteConfirmTitle => 'Supprimer le compte';

  @override
  String get profileDeleteConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action est irréversible.';

  @override
  String get profileDelete => 'Supprimer';

  @override
  String get certificatesTitle => 'Mes certificats';

  @override
  String get certificatesAchievements => 'Vos accomplissements';

  @override
  String get certificatesEarned => 'Obtenu';

  @override
  String get certificatesPending => 'En attente';

  @override
  String get certificatesInProgress => 'En cours';

  @override
  String get certificateRoadSignsMastery => 'Maîtrise des panneaux routiers';

  @override
  String get certificateTrafficRulesTest => 'Test final du code de la route';

  @override
  String get certificateDefensiveDriving => 'Conduite défensive';

  @override
  String get signsTitle => 'Panneaux de signalisation';

  @override
  String get signsSearchHint => 'Rechercher des panneaux...';

  @override
  String get signsNotFound => 'Aucun panneau de signalisation trouvé';

  @override
  String get signsLearned => 'Appris';

  @override
  String get signsAll => 'Tous';

  @override
  String get signDetailTitle => 'Panneau de signalisation';

  @override
  String get signDetailNotFound => 'Panneau non trouvé';

  @override
  String get signDetailDescription => 'Description';

  @override
  String get signDetailScenario => 'Scénario réel';

  @override
  String get signDetailLearned => 'Vous avez appris ce panneau !';

  @override
  String get signDetailMarkAsLearned => 'Marquer comme appris';

  @override
  String get signDetailMarkedSuccess => 'Panneau marqué comme appris !';

  @override
  String get subscriptionTitle => 'Accès aux examens pratiques';

  @override
  String get subscriptionSubtitle => 'Débloquer tous les examens pratiques';

  @override
  String get subscriptionTrafficRulesMsg =>
      'Si vous souhaitez apprendre le code de la route, veuillez nous appeler ou nous envoyer un message sur WhatsApp pour vous aider à préparer l\'examen officiel du permis de conduire provisoire.';

  @override
  String get subscriptionCurrentPlan => 'Votre forfait actuel';

  @override
  String get subscriptionNoPlan => 'Aucun forfait actif';

  @override
  String get subscriptionMonth1 => '1 Mois';

  @override
  String get subscriptionMonth3 => '3 Mois';

  @override
  String get subscriptionMonth6 => '6 Mois';

  @override
  String subscriptionPrice(int amount) {
    return '$amount RWF';
  }

  @override
  String get subscriptionRequestAccess => 'Demander l\'accès';

  @override
  String get subscriptionRequestSent =>
      'Votre demande a été soumise. Vous serez activé une fois le paiement confirmé.';

  @override
  String get subscriptionPaymentInstructions => 'Instructions de paiement';

  @override
  String get subscriptionPaymentMomo => 'MoMo Pay: 329494';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788659575';

  @override
  String get subscriptionPaymentTigoCash => 'Tigo Cash: 0728877442';

  @override
  String get subscriptionHelpCall => 'Appel: 0788659575';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788659575';

  @override
  String get subscriptionChoosePlan => 'Choisir un forfait';

  @override
  String get subscriptionCurrency => 'Mois à apprendre';

  @override
  String get subscriptionAccessActive => 'Accès actif';

  @override
  String subscriptionExpires(String date) {
    return 'Expire: $date';
  }

  @override
  String subscriptionDays(int days) {
    return '$days jours';
  }

  @override
  String get subscriptionNeedHelp => 'Besoin d\'aide ?';

  @override
  String subscriptionGetAccess(int count) {
    return 'Accédez à tous les $count+ examens pratiques premium';
  }

  @override
  String get adminDashboard => 'Tableau de bord administrateur';

  @override
  String get adminUsers => 'Utilisateurs';

  @override
  String get adminAccess => 'Gestion des accès';

  @override
  String get adminProgress => 'Progression des utilisateurs';

  @override
  String get adminTotalUsers => 'Utilisateurs totaux';

  @override
  String get adminActiveSubscriptions => 'Abonnements actifs';

  @override
  String get adminUsersByLanguage => 'Utilisateurs par langue';

  @override
  String get adminRecentRegistrations => 'Inscriptions récentes';

  @override
  String get adminGrantAccess => 'Accorder l\'accès';

  @override
  String get adminCallUser => 'Appeler l\'utilisateur';

  @override
  String get adminCallNotes => 'Notes d\'appel';

  @override
  String get adminLastCalled => 'Dernier appel';

  @override
  String get adminNoAccess => 'Pas d\'accès';

  @override
  String get adminHasAccess => 'A l\'accès';

  @override
  String get adminAccessExpired => 'Accès expiré';

  @override
  String adminAccessExpires(String date) {
    return 'Expire: $date';
  }

  @override
  String get adminSearchUsers => 'Rechercher des utilisateurs...';

  @override
  String get adminFilterAll => 'Tous';

  @override
  String get adminFilterHasAccess => 'A l\'accès';

  @override
  String get adminFilterNoAccess => 'Pas d\'accès';

  @override
  String get adminManageUsers => 'Gérer les utilisateurs';

  @override
  String get adminManageAccess => 'Gérer les accès';

  @override
  String get adminViewProgress => 'Voir la progression';

  @override
  String adminRegistrationDate(String date) {
    return 'Inscrit: $date';
  }

  @override
  String get adminEnterCallNotes => 'Entrez les notes d\'appel...';

  @override
  String get adminSubmitCall => 'Soumettre';

  @override
  String get adminCallLogged => 'Appel enregistré avec succès';

  @override
  String get adminAccessGranted => 'Accès accordé avec succès';

  @override
  String get adminSelectTier => 'Sélectionner le niveau d\'accès';

  @override
  String get adminCustomDays => 'Durée personnalisée (jours)';

  @override
  String get adminPaymentAmount => 'Montant (RWF)';

  @override
  String get adminEnterDays => 'Entrez le nombre de jours';

  @override
  String get adminEnterAmount => 'Entrez le montant en RWF';

  @override
  String get adminOrCustom => 'Ou définir des jours personnalisés';

  @override
  String get adminPendingRequests => 'Demandes de paiement en attente';

  @override
  String get adminAllUsersList => 'Tous les utilisateurs';

  @override
  String get adminInvalidAmount =>
      'Veuillez entrer un montant valide supérieur à 0';

  @override
  String get adminInvalidDays =>
      'Veuillez entrer un nombre de jours valide supérieur à 0';

  @override
  String get adminAccessRevoked => 'Accès révoqué';

  @override
  String get adminNoUsers => 'Aucun utilisateur trouvé';

  @override
  String get examListTitle => 'Examens pratiques';

  @override
  String get examFree => 'GRATUIT';

  @override
  String get examPaid => 'PAYANT';

  @override
  String get examLocked => 'Verrouillé';

  @override
  String examQuestions(int count) {
    return '$count questions';
  }

  @override
  String get quizProgress => 'Progression';

  @override
  String quizAnswered(int answered, int total) {
    return 'Répondu: $answered/$total';
  }

  @override
  String get quizSubmitPractice => 'Soumettre la pratique';

  @override
  String get quizPrevious => 'Précédent';

  @override
  String get quizNext => 'Suivant';

  @override
  String quizTimeRemaining(String time) {
    return 'Temps: $time';
  }

  @override
  String get quizResults => 'Résultats du quiz';

  @override
  String get quizPassed => 'Réussi !';

  @override
  String get quizFailed => 'Continuez à pratiquer';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current sur $total';
  }

  @override
  String get quizSubmitConfirmTitle => 'Soumettre le quiz ?';

  @override
  String quizSubmitConfirmMessage(int answered, int total) {
    return 'Vous avez répondu à $answered questions sur $total. Êtes-vous sûr de vouloir soumettre ?';
  }

  @override
  String get quizTimeUp => 'Temps écoulé ! Quiz soumis automatiquement.';

  @override
  String get quizReviewAnswers => 'Revoir les réponses';

  @override
  String get quizRetake => 'Repasser le quiz';

  @override
  String get profileRole => 'Rôle';

  @override
  String get profileLanguage => 'Langue préférée';

  @override
  String profileRegistered(String date) {
    return 'Inscrit: $date';
  }

  @override
  String get profileAccessStatus => 'Statut d\'accès';

  @override
  String get profileExamHistory => 'Historique des examens';

  @override
  String get profileCallHistory => 'Historique des appels';

  @override
  String get paymentInstructionsTitle => 'Instructions de paiement';

  @override
  String get paymentMomoPayNumber => 'MoMo Pay: 329494';

  @override
  String get paymentMomoPayDial =>
      'Pour payer avec MoMo Pay, composez: *182*8*1*329494*montant#';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788659575';

  @override
  String get paymentTigoCashNumber => 'Tigo Cash: 0728877442';

  @override
  String get paymentMobileMoneyDial =>
      'Pour payer avec Mobile Money, composez: *182*1*1*0788659575*montant#';

  @override
  String get paymentTigoCashDial =>
      'Pour payer avec  Tigo Cash, composez: *182*1*1*0728877442*montant#';

  @override
  String get paymentHelpText =>
      'Besoin d\'aide ? Appelez ou WhatsApp: 0788659575';

  @override
  String get paymentHelpContact =>
      'Vous pouvez copier ou appeler: 0788659575 ou WhatsApp: 0788659575 pour de l\'aide.';

  @override
  String get paymentError =>
      'La demande de paiement a échoué. Veuillez payer manuellement en utilisant les instructions ci-dessous.';

  @override
  String get paymentCopyNumber => 'Copier le numéro';

  @override
  String get paymentCallNumber => 'Appeler le 0788659575';

  @override
  String get paymentCallTigoNumber => 'Appeler le 0728877442';

  @override
  String get paymentWhatsApp => 'Envoyer un message sur WhatsApp';

  @override
  String get paymentWhatsAppMessage =>
      'Demander l\'accès à l\'application d\'examen de conduite';

  @override
  String get paymentRequestExists =>
      'Une demande de paiement pour ce forfait est déjà en attente. Veuillez attendre l\'activation ou contacter le support.';

  @override
  String get commonError =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get adminTierLabel => 'Niveau';

  @override
  String get adminExpiresLabel => 'Expire le';

  @override
  String get adminRenewAccess => 'Renouveler / Prolonger l\'accès';

  @override
  String get adminManagePlatform => 'Gérer la plateforme';

  @override
  String get adminManageExams => 'Gérer les examens';

  @override
  String get adminManageExamsDesc => 'Voir et gérer tous les examens pratiques';

  @override
  String get adminManageUsersDesc =>
      'Voir, rechercher et gérer tous les utilisateurs';

  @override
  String get adminAccessCodesDesc =>
      'Gérer les codes d\'accès et les paiements';

  @override
  String get adminQuickStats => 'Statistiques rapides';

  @override
  String get adminActionsTitle => 'Actions Admin';

  @override
  String get adminTotalPractices => 'Total des pratiques';

  @override
  String get adminManagePlatformDesc =>
      'Gérez votre plateforme d\'apprentissage du code de la route';

  @override
  String get adminNotifications => 'Notifications';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsAppearanceDesc =>
      'Choisissez l\'apparence de l\'application';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get examWrong => 'Incorrect';

  @override
  String get examTimeSpent => 'Temps';

  @override
  String get profileLogoutConfirmTitle => 'Se déconnecter?';

  @override
  String get profileLogoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get profileDeleteInstructions =>
      'Avant de supprimer votre compte:\n• Tous vos résultats d\'examen seront effacés\n• Votre abonnement sera supprimé\n• Cette action ne peut pas être annulée\n• Vous devrez vous réinscrire pour utiliser l\'application';

  @override
  String get progressExamsTaken => 'Examens passés';

  @override
  String get progressPassedCount => 'Réussis';

  @override
  String get progressFailedCount => 'Échoués';

  @override
  String get progressPassRate => 'Taux de réussite';

  @override
  String get progressNoExams => 'Aucun examen encore. Commencez à pratiquer!';

  @override
  String get certificateReadyTitle => 'Prêt pour l\'examen officiel!';

  @override
  String certificateReadySubtitle(int count) {
    return 'Vous avez réussi $count examens. Vous êtes prêt pour le test officiel.';
  }

  @override
  String get certificateIremboLink =>
      'S\'inscrire à l\'examen officiel sur irembo.gov.rw';

  @override
  String get certificateIremboDesc =>
      'Cliquez ci-dessous pour vous inscrire au test informatisé officiel du permis de conduire provisoire';

  @override
  String certificateExamsNeeded(int needed) {
    return 'Réussissez $needed examens supplémentaires pour obtenir votre certificat';
  }

  @override
  String certificateProgressLabel(int passed, int total) {
    return '$passed sur $total examens requis réussis';
  }

  @override
  String get adminSortAsc => 'Plus anciens d\'abord';

  @override
  String get adminSortDesc => 'Plus récents d\'abord';

  @override
  String get adminFilterToday => 'Aujourd\'hui';

  @override
  String get adminDateRange => 'Plage de dates';

  @override
  String get adminFilterRole => 'Rôle';

  @override
  String get adminBlockUser => 'Bloquer l\'utilisateur';

  @override
  String get adminUnblockUser => 'Débloquer l\'utilisateur';

  @override
  String get adminDeleteUserAction => 'Supprimer l\'utilisateur';

  @override
  String adminBlockUserConfirm(String name) {
    return 'Bloquer $name? Ils perdront l\'accès.';
  }

  @override
  String adminDeleteUserConfirm(String name) {
    return 'Supprimer définitivement $name? Toutes leurs données seront effacées.';
  }

  @override
  String get adminUserBlocked => 'Utilisateur bloqué avec succès';

  @override
  String get adminUserUnblocked => 'Utilisateur débloqué avec succès';

  @override
  String get adminUserDeleted => 'Utilisateur supprimé avec succès';

  @override
  String get adminMustBlockFirst =>
      'Vous devez bloquer l\'utilisateur avant de le supprimer.';

  @override
  String get adminBlockAccess => 'Bloquer l\'accès';

  @override
  String get adminDeleteAccess => 'Supprimer l\'accès';

  @override
  String get adminBlockAccessConfirm =>
      'Bloquer ce code d\'accès? L\'utilisateur perdra l\'accès immédiatement.';

  @override
  String get adminDeleteAccessConfirm =>
      'Supprimer définitivement ce code d\'accès?';

  @override
  String get adminAccessBlocked => 'Code d\'accès bloqué';

  @override
  String get adminAccessDeleted => 'Code d\'accès supprimé';

  @override
  String adminPage(int page, int total) {
    return 'Page $page sur $total';
  }

  @override
  String get adminLearningLanguage => 'Apprentissage';

  @override
  String get adminIsBlocked => 'Bloqué';

  @override
  String get adminIsActive => 'Actif';

  @override
  String get generalCopied => 'Copié !';

  @override
  String get adminRetry => 'Réessayer';

  @override
  String get languageSelectDescription =>
      'Vous pouvez changer cela plus tard dans les Paramètres — recevez des alertes trafic et itinéraires localisés.';

  @override
  String get languageSelectDeviceLanguage =>
      'Utiliser la langue de l\'appareil';

  @override
  String get languageSelectHelpTooltip => 'Aide sur la langue';

  @override
  String get languageSelectMaybeLater => 'Peut-être plus tard';

  @override
  String get languageSelectHelpTitle => 'Pourquoi choisir une langue ?';

  @override
  String get languageSelectHelpContent =>
      'Choisir une langue garantit que les alertes, cartes et invites vocales sont affichées dans votre langue préférée. Vous pouvez changer cela plus tard dans les Paramètres.';

  @override
  String get commonGotIt => 'Compris';

  @override
  String get languageSelectDialogTitle => 'Sélectionner la langue';

  @override
  String get examNotFound => 'Examen introuvable';

  @override
  String errorWithDetail(String detail) {
    return 'Erreur : $detail';
  }

  @override
  String errorUnexpected(String detail) {
    return 'Erreur inattendue : $detail';
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
  String get examSampleQ1 =>
      'Quelle est la limite de vitesse sur l\'autoroute ?';

  @override
  String get examSampleQ1A1 => '90 km/h';

  @override
  String get examSampleQ1A2 => '100 km/h';

  @override
  String get examSampleQ1A3 => '110 km/h';

  @override
  String get examSampleQ1A4 => '120 km/h';

  @override
  String get examSampleQ2 => 'Que signifie un feu jaune ?';

  @override
  String get examSampleQ2A1 => 'Arrêtez-vous immédiatement';

  @override
  String get examSampleQ2A2 => 'Continuez';

  @override
  String get examSampleQ2A3 => 'Préparez-vous à vous arrêter';

  @override
  String get examSampleQ2A4 => 'Faites demi-tour';

  @override
  String get examSampleQ3 =>
      'À quelle distance d\'une bouche d\'incendie pouvez-vous stationner ?';

  @override
  String get examSampleQ3A1 => '1 mètre';

  @override
  String get examSampleQ3A2 => '3 mètres';

  @override
  String get examSampleQ3A3 => '5 mètres';

  @override
  String get examSampleQ3A4 => '10 mètres';

  @override
  String get examShareResult => 'Partager le résultat';

  @override
  String get examCopiedToClipboard => 'Résultat copié dans le presse-papiers';

  @override
  String get examGradeLabel => 'Note';

  @override
  String get subscriptionPopular => '★ Populaire';

  @override
  String get quizTimeTaken => 'Temps passé';

  @override
  String get progressTotalQuestions => 'Total des questions';

  @override
  String get progressCorrectAnswers => 'Correctes';

  @override
  String get progressIncorrect => 'Incorrectes';

  @override
  String get errorNetwork =>
      'Connexion impossible. Vérifiez votre connexion internet et réessayez.';

  @override
  String get paymentChooseMethod => 'Choisir le mode de paiement';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutAppName => 'Rwanda Traffic Rule';

  @override
  String get aboutDescription =>
      'Rwanda Traffic Rule est votre compagnon pour apprendre le code de la route rwandais, les panneaux routiers et pratiquer les questions théoriques pour préparer l\'examen du permis provisoire. Cette application éducative indépendante n\'est affiliée à aucune autorité gouvernementale.';

  @override
  String get aboutFeatures => 'Fonctionnalités clés';

  @override
  String get aboutFeaturePractice => 'Examens blancs';

  @override
  String get aboutFeatureProgress => 'Suivi des progrès';

  @override
  String get aboutFeatureMultilingual => '3 Langues';

  @override
  String get aboutFeatureCertificate => 'Certificats';

  @override
  String get aboutContact => 'Contactez-nous';

  @override
  String get aboutContactInfo =>
      'Tél/WhatsApp : 0788659575 / 0728877442\nEmail : info@Rwanda Traffic Rule.rw';

  @override
  String get aboutCopyright => 'Droits d\'auteur';

  @override
  String get aboutCopyrightText =>
      '© 2026 Rwanda Traffic Rule. Tous droits réservés.';

  @override
  String get privacyLastUpdated => 'Dernière mise à jour : mars 2026';

  @override
  String get privacyIntro =>
      'Rwanda Traffic Rule s\'engage à protéger votre vie privée. Cette politique explique comment nous collectons, utilisons et protégeons vos informations personnelles. Nous sommes un service éducatif indépendant non affilié à aucune autorité gouvernementale.';

  @override
  String get privacyDataCollection => 'Collecte des données';

  @override
  String get privacyDataCollectionBody =>
      'Nous collectons votre numéro de téléphone et votre nom complet lors de l\'inscription. Nous collectons également vos résultats de quiz et données de progression. Un identifiant d\'appareil unique est généré pour sécuriser votre compte.';

  @override
  String get privacyDataUsage => 'Utilisation des données';

  @override
  String get privacyDataUsageBody =>
      'Vos données sont utilisées pour fournir et améliorer nos services, suivre vos progrès, gérer votre abonnement et communiquer les mises à jour importantes.';

  @override
  String get privacyDataProtection => 'Protection des données';

  @override
  String get privacyDataProtectionBody =>
      'Nous utilisons des mesures de sécurité standards, notamment la transmission chiffrée et le stockage sécurisé. Vos données ne sont jamais partagées sans votre consentement.';

  @override
  String get privacyDataSharing => 'Partage des données';

  @override
  String get privacyDataSharingBody =>
      'Nous ne vendons ni ne louons vos données personnelles. Nous pouvons partager des données anonymes agrégées à des fins statistiques uniquement.';

  @override
  String get privacyUserRights => 'Vos droits';

  @override
  String get privacyUserRightsBody =>
      'Vous avez le droit d\'accéder, de mettre à jour ou de supprimer vos données personnelles à tout moment via l\'option Supprimer le compte dans les Paramètres.';

  @override
  String get termsLastUpdated => 'Dernière mise à jour : mars 2026';

  @override
  String get termsIntro =>
      'En utilisant Rwanda Traffic Rule, vous acceptez les conditions suivantes. Rwanda Traffic Rule est une application éducative indépendante conçue pour vous aider à préparer l\'examen théorique. Nous ne sommes affiliés à aucune autorité gouvernementale.';

  @override
  String get termsAcceptance => 'Acceptation des conditions';

  @override
  String get termsAcceptanceBody =>
      'En créant un compte et en utilisant cette application, vous acceptez d\'être lié par ces conditions. Si vous n\'êtes pas d\'accord, veuillez cesser d\'utiliser l\'application.';

  @override
  String get termsUserAccount => 'Compte utilisateur';

  @override
  String get termsUserAccountBody =>
      'Vous êtes responsable de la sécurité de votre compte. Chaque compte est lié à un seul numéro de téléphone et appareil. Le partage des identifiants n\'est pas autorisé.';

  @override
  String get termsContent => 'Contenu et examens';

  @override
  String get termsContentBody =>
      'Tout le contenu est à des fins éducatives et de pratique uniquement. Il ne représente pas l\'examen officiel du gouvernement. Nous ne garantissons pas les résultats d\'examen. Rwanda Traffic Rule n\'est affilié à aucune autorité gouvernementale.';

  @override
  String get termsPayment => 'Demander à débloquer les examens';

  @override
  String get termsPaymentBody =>
      'Pour débloquer les examens, veuillez nous contacter au 0788659575 ou 0728877442.';

  @override
  String get termsTermination => 'Suppression du compte';

  @override
  String get termsTerminationBody =>
      'Vous pouvez supprimer votre compte à tout moment depuis les paramètres.';

  @override
  String get aboutDisclaimer => 'Avertissement';

  @override
  String get aboutDisclaimerText =>
      'Rwanda Traffic Rule est une application éducative indépendante conçue pour aider les utilisateurs à apprendre le code de la route et à se préparer à l\'examen théorique. Cette application n\'est pas affiliée, approuvée ou liée à une autorité gouvernementale ou un organisme d\'examen officiel. Tout le contenu est à des fins de pratique et d\'apprentissage uniquement.';

  @override
  String get profileCertificatesTitle => 'Certificats';

  @override
  String get profileCertificatesSubtitle =>
      'Certificats obtenus et progression vers le prochain';

  @override
  String get offlineBanner =>
      'Vous êtes hors ligne. Les données affichées peuvent ne pas être à jour.';

  @override
  String get syncingData => 'Synchronisation des données...';

  @override
  String get dataSynced => 'Données synchronisées avec succès';

  @override
  String get savedOffline =>
      'Enregistré hors ligne. Sera synchronisé une fois connecté.';

  @override
  String certificateUniqueExamsPassed(int count, int total) {
    return '$count sur $total examens uniques réussis';
  }

  @override
  String certificatePassMark(int required, int total, int percent) {
    return 'Note de passage : $required/$total ($percent%)';
  }

  @override
  String get certificateLatestAttempt => 'Dernière tentative';

  @override
  String certificateExamStatus(int index) {
    return 'Examen $index';
  }

  @override
  String get certificateNotAttempted => 'Non tenté';

  @override
  String get consentTitle => 'Votre vie privée compte';

  @override
  String get consentBody =>
      'Rwanda Traffic Rule collecte et traite les données suivantes pour vous offrir la meilleure expérience d\'apprentissage :\n\n• Numéro de téléphone et nom — pour la création de compte et l\'authentification\n• Identifiant de l\'appareil — une empreinte numérique chiffrée pour sécuriser votre compte\n• Résultats d\'examens et progression — pour suivre votre parcours d\'apprentissage\n• Cache hors ligne — pour que l\'application fonctionne sans internet\n\nVos données sont stockées de manière sécurisée et ne sont jamais vendues à des tiers. Vous pouvez supprimer votre compte et toutes les données associées à tout moment depuis votre profil.';

  @override
  String get consentAccept => 'Je comprends et j\'accepte';

  @override
  String get consentReadPolicy => 'Lire la politique de confidentialité';

  @override
  String get registerInvalidName =>
      'Le nom doit contenir uniquement des lettres et des espaces';

  @override
  String get registerInvalidPhone =>
      'Entrez un numéro de téléphone valide (ex: 078... ou +250 78...)';

  @override
  String get joinGroup => 'Groupe WhatsApp';

  @override
  String get joinGroupSubtitle => 'Rejoindre un groupe WhatsApp';

  @override
  String get adminOfflineTooltip =>
      'Hors ligne – affichage des données mises en cache';

  @override
  String get adminOfflineBadge => 'HORS LIGNE';

  @override
  String adminActiveLabel(int count) {
    return '$count actifs';
  }

  @override
  String get adminFallbackName => 'Administrateur';

  @override
  String get adminNoNetworkError =>
      'Pas de réseau. Aucune donnée mise en cache disponible.';

  @override
  String get commonErrorTitle => 'Erreur';

  @override
  String get exitAppTitle => 'Quitter l\'application';

  @override
  String get exitAppMessage =>
      'Êtes-vous sûr de vouloir quitter l\'application ?';

  @override
  String get exitAppYes => 'Quitter';

  @override
  String get exitAppNo => 'Rester';

  @override
  String get consentItemPhone => 'Numéro de téléphone et nom';

  @override
  String get consentItemPhoneDetail => 'Création de compte et authentification';

  @override
  String get consentItemDevice => 'Identifiant de l\'appareil';

  @override
  String get consentItemDeviceDetail =>
      'Empreinte numérique hachée pour sécuriser votre compte';

  @override
  String get consentItemProgress => 'Résultats d\'examens et progression';

  @override
  String get consentItemProgressDetail =>
      'Suivez votre parcours d\'apprentissage';

  @override
  String get consentItemCache => 'Cache hors ligne';

  @override
  String get consentItemCacheDetail =>
      'L\'application fonctionne sans internet';

  @override
  String get consentSecurityNote =>
      'Vos données sont stockées de manière sécurisée et ne sont jamais vendues à des tiers.';

  @override
  String get consentIndependentTitle => 'Contenu indépendant';

  @override
  String get consentIndependentBody =>
      'Ceci est un outil éducatif indépendant. Il n\'est PAS affilié, approuvé ou représentant d\'une entité gouvernementale ou de la Police Nationale du Rwanda.';

  @override
  String get dashboardWelcome => 'Bienvenue';

  @override
  String get dashboardNotices => 'NOTIFICATIONS';

  @override
  String get dashboardWhatsapp => 'Groupe WhatsApp';

  @override
  String get dashboardGazette => 'NOUVEAU JOURNAL OFFICIEL';

  @override
  String get dashboardShare => 'Partager l’application';

  @override
  String get dashboardProfileUnavailable => 'Profil indisponible';

  @override
  String get dashboardLoading => 'Chargement de l’abonnement…';

  @override
  String get dashboardSubscriptionUnavailable =>
      'Abonnement indisponible. Faites glisser vers le bas pour réessayer.';

  @override
  String get dashboardExpired => 'Votre accès aux cours a expiré';

  @override
  String get dashboardDurationUnavailable => 'Non disponible';

  @override
  String dashboardDuration(String duration) {
    return 'Durée : $duration';
  }

  @override
  String get dashboardCached =>
      'État enregistré · faites glisser pour actualiser';

  @override
  String get dashboardNoticesUnavailable =>
      'Les notifications sont indisponibles pour le moment. Réessayez plus tard.';

  @override
  String get dashboardNoNotices => 'Aucune notification pour le moment';

  @override
  String get dashboardCopyLink => 'Copier le lien';

  @override
  String get dashboardLinkCopied => 'Lien copié';

  @override
  String get dashboardOpenFailed =>
      'Impossible de terminer cette action. Réessayez.';

  @override
  String get dashboardComingSoon => 'Bientôt disponible';

  @override
  String get dashboardUnderDevelopment =>
      'Cette fonctionnalité est en cours de développement.';

  @override
  String get dashboardExamsLocked => 'Les examens sont verrouillés';

  @override
  String get dashboardRequestExamAccess =>
      'Appuyez ici pour demander l’accès aux examens';

  @override
  String get paymentExamLanguage => 'Langue des examens';

  @override
  String get paymentExamLanguageHint =>
      'Choisissez la langue de vos examens. Cela ne change pas la langue de l’application.';

  @override
  String paymentAmountToPay(String amount) {
    return 'Montant à payer : $amount RWF';
  }

  @override
  String get paymentMethodLabel => 'Mode de paiement';

  @override
  String get paymentNotConfigured =>
      'Les coordonnées de paiement ne sont pas encore configurées.';

  @override
  String get paymentUssdLabel => 'Code USSD de paiement';

  @override
  String get paymentCopyCode => 'Copier le code';

  @override
  String get paymentCodeCopied => 'Code copié';

  @override
  String get paymentCopyFailed =>
      'Impossible de copier le code. Réessayez ou copiez-le manuellement.';

  @override
  String get paymentUssdInstruction =>
      'Copiez ce code et composez-le sur votre téléphone pour effectuer le paiement.';

  @override
  String get paymentPayNow => 'PAYER MAINTENANT';

  @override
  String get paymentIntegrationPending =>
      'Les détails du paiement sont prêts. Le paiement n’est pas encore intégré ; aucun paiement n’a été confirmé.';

  @override
  String get paymentPreparationFailed =>
      'Impossible de préparer le paiement. Veuillez réessayer.';

  @override
  String paymentRecipient(String name, String method) {
    return '$method enregistré au nom de : $name';
  }

  @override
  String get paymentVerifyRecipient =>
      'Avant de confirmer le paiement, vérifiez que le nom du bénéficiaire affiché sur votre téléphone correspond au nom indiqué ici. Sinon, ne poursuivez pas.';

  @override
  String get dashboardGazetteSubtitle => 'Code de la route';

  @override
  String get dashboardIremboSubtitle => 'Services en ligne';

  @override
  String get guideTitle => 'Instructions';

  @override
  String get guideWelcome => 'Bienvenue sur RWANDA TRAFFIC RULE';

  @override
  String get guideAboutTitle => '1. À propos de l’application';

  @override
  String get guideAboutBody => 'RWANDA TRAFFIC RULE vous aide à apprendre le code de la route et à préparer l’examen du permis provisoire grâce à des questions d’entraînement.';

  @override
  String get guideUseTitle => '2. Comment utiliser l’application';

  @override
  String get guideUseBody => '1. Lors de votre première visite, inscrivez-vous avec votre nom complet et votre numéro de téléphone.\n\n2. Si vous avez déjà un compte, choisissez Se connecter et saisissez votre numéro enregistré. Suivez les éventuelles étapes supplémentaires de connexion.\n\n3. Ouvrez Entraînement depuis l’accueil et choisissez un examen. Les examens gratuits sont accessibles sans abonnement ; les examens verrouillés nécessitent un accès actif.\n\n4. Choisissez une réponse et consultez la correction. Le vert indique une bonne réponse et le rouge une mauvaise réponse. Passez à la question suivante, terminez l’examen pour voir votre score et consultez vos résultats dans Progression.';

  @override
  String get guideExamTitle => '3. Préparer l’examen sur ordinateur';

  @override
  String get guideExamBody => 'Les questions d’entraînement vous habituent à lire les questions et à choisir des réponses à l’écran. Pendant l’examen officiel, suivez les consignes pour passer d’une question à l’autre et soumettre vos réponses.\n\nLes corrections vous aident à apprendre. Les questions, la durée et les corrections de l’examen officiel peuvent différer ; cette application ne garantit pas un contenu identique.';

  @override
  String get guidePaymentTitle => '4. Paiement et accès aux examens';

  @override
  String get guidePaymentBody => '1. Appuyez sur la bannière d’accès de l’accueil ou sur un examen verrouillé pour ouvrir la page d’accès aux examens.\n\n2. Choisissez 1, 3 ou 6 mois. L’application sélectionne d’abord 1 mois en kinyarwanda et 3 mois en anglais ou en français. Le montant en RWF change avec la durée ; le tarif dépend de la langue de l’application.\n\n3. MoMo Pay est sélectionné par défaut. Vous pouvez choisir MTN ou Tigo. Vérifiez le titulaire affiché : Alexis pour MoMo Pay, ou NSHIMIYIMANA Alexis pour MTN et Tigo. Comparez ce nom avec celui affiché sur votre téléphone avant de confirmer.\n\n4. Appuyez sur PAYER MAINTENANT pour copier le code USSD complet et ouvrir le composeur. Terminez le paiement sur votre téléphone. L’icône de copie permet aussi de copier le code et de le composer manuellement.\n\n5. Après le paiement, utilisez les boutons d’appel ou WhatsApp de la rubrique Besoin d’aide pour demander l’activation avec votre numéro enregistré dans l’application. Ouvrir le composeur ou copier le code n’active pas les examens.\n\n6. Une fois l’accès actif attribué à votre compte par un administrateur, revenez à l’accueil avec Internet et appuyez sur une flèche circulaire. La bannière se met à jour et les examens payants deviennent accessibles. Aucun code n’est à saisir sur cette page. L’application vérifie aussi l’accès à l’ouverture de l’accueil, à votre retour dans l’application et régulièrement lorsque l’accueil est actif.\n\n7. Si les examens restent verrouillés, vérifiez que l’assistance a utilisé votre numéro enregistré et que l’accès n’a pas expiré. Contactez l’assistance avec les boutons ci-dessous.';

  @override
  String get guideOpenAccess => 'Voir les offres et payer';

  @override
  String get dashboardRefresh => 'Actualiser l’accès';

  @override
  String get dashboardRefreshDone => 'État de l’accès actualisé.';

  @override
  String get dashboardRefreshFailed => 'Impossible d’actualiser l’accès. Vérifiez votre connexion Internet et réessayez.';

  @override
  String get resourcesTitle => 'Documents';

  @override
  String get resourcesDescription => 'Consultez le Journal officiel et les panneaux routiers dans l’application. Les documents sont inclus pour une lecture hors ligne et conservent leur langue d’origine.';

  @override
  String get resourcesGazette => 'Journal officiel';

  @override
  String get resourcesRoadSigns => 'Panneaux routiers';

  @override
  String get resourcesOfflinePdf => 'PDF • Lecture hors ligne';

  @override
  String get resourcesReadError => 'Impossible d’ouvrir ce document. Réessayez.';

  @override
  String get resourcesPreviousPage => 'Page précédente';

  @override
  String get resourcesNextPage => 'Page suivante';

  @override
  String get resourcesZoomOut => 'Réduire';

  @override
  String get resourcesZoomIn => 'Agrandir';

  @override
  String get resourcesLoading => 'Chargement du document…';

  @override
  String resourcesPageCount(int page, int total) => 'Page $page sur $total';
  @override
  String get irTitle => "Services Irembo";

  @override
  String get irWorkspace => "Demandes Irembo";

  @override
  String get irMyRequests => "Mes demandes Irembo";

  @override
  String get irNew => "Nouvelle demande";

  @override
  String get irManual => "Manuelle";

  @override
  String get irAutomatic => "Automatique";

  @override
  String get irNotice => "Ceci crée une demande dans cette application, et non une inscription confirmée sur la plateforme officielle Irembo.";

  @override
  String get irFullName => "Nom complet";

  @override
  String get irPhone => "Numéro de téléphone";

  @override
  String get irNationalId => "Numéro de carte d’identité";

  @override
  String get irDob => "Date de naissance";

  @override
  String get irExamLanguage => "Langue de l’examen";

  @override
  String get irLanguageHint => "p. ex., kinyarwanda, anglais, français";

  @override
  String get irDistrict => "District souhaité pour l’examen";

  @override
  String get irExamDate => "Date souhaitée (facultative)";

  @override
  String get irDateNotice => "La date souhaitée n’est pas un rendez-vous confirmé.";

  @override
  String get irProvisoireCode => "Code du permis provisoire";

  @override
  String get irCategory => "Catégorie du permis";

  @override
  String get irService => "Service";

  @override
  String get irOption => "Option du permis";

  @override
  String get irReview => "Vérifier la demande";

  @override
  String get irConfirm => "Confirmer et envoyer";

  @override
  String get irEdit => "Modifier les informations";

  @override
  String get irSaved => "Demande enregistrée";

  @override
  String get irReference => "Référence de la demande";

  @override
  String get irStatus => "Statut";

  @override
  String get irSubmitted => "Date de soumission";

  @override
  String get irUpdated => "Dernière modification";

  @override
  String get irAssigned => "Agent responsable";

  @override
  String get irUnassigned => "Non attribuée";

  @override
  String get irPending => "En attente";

  @override
  String get irInReview => "En cours d’examen";

  @override
  String get irNeedsInformation => "Informations requises";

  @override
  String get irCompleted => "Terminée";

  @override
  String get irRejected => "Rejetée";

  @override
  String get irCancelled => "Annulée";

  @override
  String get irSearch => "Rechercher référence, nom ou téléphone";

  @override
  String get irFilters => "Filtres";

  @override
  String get irApply => "Appliquer les filtres";

  @override
  String get irClear => "Effacer les filtres";

  @override
  String get irAll => "Tous";

  @override
  String get irFrom => "Soumise à partir du";

  @override
  String get irTo => "Soumise jusqu’au";

  @override
  String get irNewest => "Plus récentes";

  @override
  String get irOldest => "Plus anciennes";

  @override
  String get irSort => "Trier par";

  @override
  String get irEmpty => "Aucune demande correspondante.";

  @override
  String get irView => "Voir les détails";

  @override
  String get irCall => "Appeler le demandeur";

  @override
  String get irCopy => "Copier";

  @override
  String get irCopyAll => "Copier les coordonnées";

  @override
  String get irCopied => "Copié";

  @override
  String get irCopyFailed => "Copie impossible. Réessayez.";

  @override
  String get irCallFailed => "Impossible d’ouvrir l’application téléphone.";

  @override
  String get irMessages => "Messages au demandeur";

  @override
  String get irInternalNotes => "Notes internes";

  @override
  String get irInternalHint => "Visibles uniquement au personnel";

  @override
  String get irMessage => "Message au demandeur";

  @override
  String get irReason => "Motif (visible au demandeur)";

  @override
  String get irReasonRequired => "Indiquez un motif pour ce statut.";

  @override
  String get irAudit => "Historique des modifications";

  @override
  String get irSave => "Enregistrer";

  @override
  String get irRetry => "Réessayer";

  @override
  String get irClose => "Fermer";

  @override
  String get irRequired => "Ce champ est obligatoire.";

  @override
  String get irInvalid => "Vérifiez les informations saisies.";

  @override
  String get irInvalidId => "Saisissez exactement 16 chiffres.";

  @override
  String get irInvalidPhone => "Saisissez un numéro mobile rwandais valide.";

  @override
  String get irUnavailable => "Impossible de terminer. Vérifiez la connexion et réessayez. Les informations saisies restent sur cette page.";

  @override
  String get irConflict => "Cette demande a été modifiée ou déjà envoyée. Actualisez la liste avant de réessayer.";

  @override
  String get irNext => "Suivant";

  @override
  String get irPrevious => "Précédent";

  @override
  String get irCreated => "Demande créée";

  @override
  String get irChange => "Modification";

  @override
  String get irNoMessages => "Aucun message pour le moment.";

  @override
  String get irResults => "Résultats";

  @override
  String get irSelectDistrict => "Rechercher et choisir un district";

  @override
  String get irEnglish => "Anglais";

  @override
  String get irFrench => "Français";

  @override
  String get irKinyarwanda => "Kinyarwanda";

}
