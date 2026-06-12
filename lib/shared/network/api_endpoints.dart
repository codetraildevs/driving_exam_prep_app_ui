class ApiEndpoints {
  // Auth
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authLogout = '/api/auth/logout';
  static const String authRefresh = '/api/auth/refresh';

  // Users
  static String user(String id) => '/api/users/$id';

  // Exam results
  static String examResultsForUser(String userId) => '/api/exam-results/$userId';

  // Traffic signs (optional; backend may not implement yet)
  static const String signs = '/api/signs';
  static String signById(String id) => '/api/signs/$id';
  static String signProgress(String userId, String signId) =>
      '/api/users/$userId/signs/$signId/progress';
  static String markSignLearned(String userId, String signId) =>
      '/api/users/$userId/signs/$signId/learned';
  static const String signCategories = '/api/signs/categories';
}

