// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application d\'apprentissage du code de la route';

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
  String get settingsAboutApp => 'À propos de l\'application';

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
  String get commonConfirm => 'Confirmer';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get landingHeroTitle => 'Maîtrisez le code de la route facilement';

  @override
  String get landingHeroSubtitle =>
      'Préparez-vous intelligemment. Entraînez-vous avec de vraies questions d\'examen. Suivez vos progrès et réussissez votre permis de conduire en toute confiance.';

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
  String get authAppName => 'CODE DE LA ROUTE RWANDA';

  @override
  String get authSubtitle =>
      'Plateforme officielle d\'apprentissage du permis de conduire';

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
  String get authPhoneHint => '0788 000 000';

  @override
  String get authContinue => 'Continuer';

  @override
  String get loginNoAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get loginSignUp => 'S\'inscrire';

  @override
  String get authSecureTag => 'Sécurisé • Rapide • Application officielle';

  @override
  String get loginPhoneRequired => 'Veuillez entrer votre numéro de téléphone';

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
  String get subscriptionPaymentMomo => 'MoMo Pay: 323294';

  @override
  String get subscriptionPaymentMobile => 'Mobile Money: 0788657595';

  @override
  String get subscriptionHelpCall => 'Appel: 0788657595';

  @override
  String get subscriptionHelpWhatsapp => 'WhatsApp: 0788657595';

  @override
  String get subscriptionChoosePlan => 'Choisir un forfait';

  @override
  String get subscriptionCurrency => 'Devise: RWF';

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
  String get paymentMomoPayNumber => 'MoMo Pay: 323294';

  @override
  String get paymentMomoPayDial => 'Pour payer avec MoMo Pay, composez: *182*1*1*323294*montant#';

  @override
  String get paymentMobileMoneyNumber => 'Mobile Money: 0788657595';

  @override
  String get paymentMobileMoneyDial => 'Pour payer avec Mobile Money, composez: *182*8*1*0788657595*montant#';

  @override
  String get paymentHelpText =>
      'Besoin d\'aide ? Appelez ou WhatsApp: 0788657595';

  @override
  String get paymentHelpContact =>
      'Vous pouvez copier ou appeler: 0788657595 ou WhatsApp: 0788657595 pour de l\'aide.';

  @override
  String get paymentError =>
      'La demande de paiement a échoué. Veuillez payer manuellement en utilisant les instructions ci-dessous.';

  @override
  String get paymentCopyNumber => 'Copier le numéro';

  @override
  String get paymentCallNumber => 'Appeler le 0788657595';

  @override
  String get paymentWhatsApp => 'WhatsApp: Envoyer un message';

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
}
