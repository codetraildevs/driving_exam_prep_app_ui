<?php
/**
 * API route definitions.
 * Each entry: [METHOD, PATH, HANDLER_FUNCTION_NAME]
 */

return [
    // Health & Root
    ['GET', '/', 'rootHandler'],
    ['GET', '/health', 'healthCheck'],
    ['GET', '/api/health', 'healthCheck'],

    // Auth
    ['POST', '/api/auth/register', 'authRegister'],
    ['POST', '/api/auth/login', 'authLogin'],
    ['POST', '/api/auth/rebind-device', 'authRebindDevice'],
    ['POST', '/api/auth/logout', 'authLogout'],
    ['POST', '/api/auth/refresh', 'authRefresh'],

    // Users
    ['GET', '/api/users/:id', 'getUser'],
    ['GET', '/api/users', 'listUsers'],
    ['PUT', '/api/users/:id', 'updateUser'],
    ['DELETE', '/api/users/:id', 'deleteUser'],

    // Exams
    ['GET', '/api/exams', 'getExams'],
    // stats endpoint must be declared before the generic /api/exams/:id route,
    // otherwise "stats" will be treated as an exam id and result in a 404.
    ['GET', '/api/exams/stats', 'getExamStats'],
    ['GET', '/api/exams/:id', 'getExam'],
    ['GET', '/api/exams/:id/take-exam', 'getExamQuestionsForTaking'],
    ['POST', '/api/exams', 'createExam'],
    ['PUT', '/api/exams/:id', 'updateExam'],
    ['PATCH', '/api/exams/:id/activate', 'activateExam'],
    ['PATCH', '/api/exams/:id/deactivate', 'deactivateExam'],
    ['PUT', '/api/exams/:id/toggle-status', 'toggleExamStatus'],
    ['DELETE', '/api/exams/:id', 'deleteExam'],
    ['GET', '/api/exams/:examId/analytics', 'getExamAnalytics'],

    // Questions
    ['GET', '/api/questions', 'getQuestions'],
    ['GET', '/api/questions/:id', 'getQuestion'],
    ['GET', '/api/exams/:examId/questions', 'getExamQuestions'],
    ['POST', '/api/questions', 'createQuestion'],
    ['PUT', '/api/questions/:id', 'updateQuestion'],

    // Exam Results
    ['POST', '/api/exam-results', 'submitExamResult'],
    ['POST', '/api/practice-results', 'submitPracticeResult'],
    ['POST', '/api/practice-results/reset', 'resetPracticeResults'],
    ['GET', '/api/exam-results/:userId', 'getUserResults'],
    ['GET', '/api/exam-results', 'getAllResults'],

    // Access Codes
    ['POST', '/api/access-codes/verify', 'verifyAccessCode'],
    ['GET', '/api/access-codes/status', 'getAccessCodeStatus'],
    ['GET', '/api/access-codes', 'listAccessCodes'],
    ['POST', '/api/access-codes', 'generateAccessCode'],
    ['PATCH', '/api/access-codes/:id/block', 'blockAccessCode'],
    ['DELETE', '/api/access-codes/:id', 'deleteAccessCode'],

    // Courses (aliases for exams)
    ['GET', '/api/courses', 'getCourses'],
    ['GET', '/api/courses/:id', 'getCourse'],
    ['POST', '/api/courses', 'createCourse'],

    // Payments
    ['POST', '/api/payments/request', 'requestPayment'],
    ['GET', '/api/payments', 'listPayments'],

    // Pricing (public)
    ['GET', '/api/pricing', 'getPricingPlans'],

    // Admin
    ['GET', '/api/admin/users', 'adminListUsers'],
    ['GET', '/api/admin/analytics', 'adminAnalytics'],
    ['PATCH', '/api/admin/users/:userId/block', 'adminBlockUser'],
    ['DELETE', '/api/admin/users/:userId', 'adminDeleteUser'],
    ['POST', '/api/admin/users/:userId/grant-access', 'adminGrantAccess'],
    ['POST', '/api/admin/users/:userId/mark-called', 'adminMarkCalled'],

    // Analytics
    ['GET', '/api/analytics/stats', 'getAnalytics'],

    // Notifications
    ['GET', '/api/notifications', 'getNotifications'],
    ['POST', '/api/notifications', 'createNotification'],
];
