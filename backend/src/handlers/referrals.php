<?php
require_once __DIR__ . '/../ReferralService.php';

// Personal details are available only through these role-protected admin routes.
function adminReferrals($db, $params): void {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);
    $offset = max(0, min(1000000, (int)($_GET['offset'] ?? 0)));
    $limit = 20;
    $userId = $params['userId'] ?? null;
    try {
        if ($userId !== null) {
            $user = ReferralService::query($db,
                'SELECT u.id, u.fullName, u.phoneNumber, c.code FROM users u LEFT JOIN referral_codes c ON c.userId = u.id WHERE u.id = ?',
                [$userId])->fetch(PDO::FETCH_ASSOC);
            if (!$user) ErrorHandler::notFound('User not found');
            $total = (int)ReferralService::query($db,
                'SELECT COUNT(*) AS total FROM referrals WHERE referrerId = ?', [$userId])->fetch(PDO::FETCH_ASSOC)['total'];
            $items = ReferralService::query($db,
                'SELECT r.id, u.fullName, u.phoneNumber, r.status, r.rewardStatus, r.createdAt FROM referrals r LEFT JOIN users u ON u.id = r.referredUserId WHERE r.referrerId = ? ORDER BY r.createdAt DESC, r.id DESC LIMIT ' . $limit . ' OFFSET ' . $offset,
                [$userId])->fetchAll(PDO::FETCH_ASSOC);
            respond(['user' => $user, 'items' => $items, 'total' => $total,
                'nextOffset' => $offset + count($items) < $total ? $offset + count($items) : null]);
        }
        $search = $_GET['search'] ?? '';
        if (!is_string($search) || strlen($search) > 255) ErrorHandler::badRequest('Invalid search');
        $search = trim($search);
        $where = '';
        $values = [];
        if ($search !== '') {
            $escape = static function ($value) { return str_replace(['!', '%', '_'], ['!!', '!%', '!_'], $value); };
            $phone = preg_match('/^[+0-9 ()-]+$/D', $search) ? SecurityUtils::normalizePhone($search) : $search;
            $where = " WHERE (u.fullName LIKE ? ESCAPE '!' OR u.phoneNumber LIKE ? ESCAPE '!' OR c.code LIKE ? ESCAPE '!')";
            $values = ['%' . $escape($search) . '%', '%' . $escape($phone) . '%', '%' . $escape(strtoupper($search)) . '%'];
        }
        $from = ' FROM users u LEFT JOIN referral_codes c ON c.userId = u.id';
        $total = (int)ReferralService::query($db, 'SELECT COUNT(*) AS total' . $from . $where, $values)->fetch(PDO::FETCH_ASSOC)['total'];
        $items = ReferralService::query($db,
            'SELECT u.id, u.fullName, u.phoneNumber, c.code, (SELECT COUNT(*) FROM referrals r WHERE r.referrerId = u.id) AS invitedCount'
            . $from . $where . ' ORDER BY invitedCount DESC, u.fullName ASC, u.id ASC LIMIT ' . $limit . ' OFFSET ' . $offset,
            $values)->fetchAll(PDO::FETCH_ASSOC);
        foreach ($items as &$item) $item['invitedCount'] = (int)$item['invitedCount'];
        unset($item);
        respond(['items' => $items, 'total' => $total,
            'nextOffset' => $offset + count($items) < $total ? $offset + count($items) : null]);
    } catch (Throwable $e) {
        Logger::error('Admin referral lookup failed');
        error('Referral service unavailable. Please try again later.', 503);
    }
}

function referralDashboard($db, $params): void {
    global $tokenData;
    $id = $tokenData['userId'] ?? '';
    try {
        $db->exec('START TRANSACTION');
        $user = ReferralService::query($db, 'SELECT id FROM users WHERE id = ? AND isActive = 1 FOR UPDATE', [$id])->fetch(PDO::FETCH_ASSOC);
        if (!$user) {
            $db->exec('ROLLBACK');
            ErrorHandler::forbidden('Account unavailable');
        }
        $code = ReferralService::ensureCode($db, $id);
        $db->exec('COMMIT');
        $stats = ReferralService::query($db,
            "SELECT COUNT(*) AS total, COALESCE(SUM(status = 'confirmed'), 0) AS confirmed, COALESCE(SUM(status = 'pending'), 0) AS pending FROM referrals WHERE referrerId = ?", [$id])->fetch(PDO::FETCH_ASSOC);
        $offset = max(0, min(1000000, (int)($_GET['offset'] ?? 0)));
        // Do not expose invitees' names, phone numbers or account identifiers.
        $history = ReferralService::query($db,
            'SELECT id, status, rewardStatus, createdAt FROM referrals WHERE referrerId = ? ORDER BY createdAt DESC, id DESC LIMIT 20 OFFSET ' . $offset, [$id])->fetchAll(PDO::FETCH_ASSOC);
        respond([
            'code' => $code, 'link' => ReferralService::invitation($code),
            'total' => (int)$stats['total'], 'confirmed' => (int)$stats['confirmed'], 'pending' => (int)$stats['pending'],
            'rewardsConfigured' => false, 'history' => $history,
            'nextOffset' => $offset + count($history) < (int)$stats['total'] ? $offset + count($history) : null,
        ]);
    } catch (Throwable $e) {
        $db->exec('ROLLBACK');
        Logger::error('Referral dashboard unavailable');
        error('Referral service unavailable. Please try again later.', 503);
    }
}

function referralLanding($db, $params): void {
    $code = $_GET['code'] ?? '';
    $valid = ReferralService::validCode($code);
    if ($valid) {
        $valid = (bool)ReferralService::query($db,
            'SELECT c.code FROM referral_codes c JOIN users u ON u.id = c.userId WHERE c.code = ? AND u.isActive = 1', [$code])->fetch(PDO::FETCH_ASSOC);
    }
    $language = $_GET['lang'] ?? substr($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'en', 0, 2);
    if (!in_array($language, ['en', 'fr', 'rw'], true)) $language = 'en';
    $copy = [
        'en' => ['Learn together. Drive with confidence.', 'A friend invited you to Rwanda Traffic Rules. Prepare for your driving theory exam with practice questions and road signs.', 'Get the app on Google Play', 'After installing, open the app and create your account. Your invitation is applied automatically when you install using this button.', 'Already installed? Open the invitation again after installation. If it opens in a browser, enable supported links in the app settings or tap Open in app in your browser.', 'This invitation is invalid or no longer available. You can still download the app.', 'Invitations currently track successful registrations. No rewards are offered yet.'],
        'fr' => ['Apprenez ensemble. Conduisez en confiance.', 'Un ami vous invite sur Rwanda Traffic Rules. Préparez votre examen théorique avec des questions et des panneaux routiers.', 'Télécharger sur Google Play', 'Après installation, ouvrez l’application et créez votre compte. Votre invitation sera appliquée automatiquement si vous utilisez ce bouton.', 'Déjà installée ? Rouvrez l’invitation après installation. Si le navigateur s’ouvre, activez les liens compatibles dans les paramètres de l’application ou choisissez Ouvrir dans l’application.', 'Cette invitation est invalide ou indisponible. Vous pouvez toujours télécharger l’application.', 'Les invitations suivent actuellement les inscriptions réussies. Aucune récompense n’est proposée pour le moment.'],
        'rw' => ['Twigire hamwe. Dutware twizeye.', 'Inshuti yagutumiye kuri Rwanda Traffic Rules. Itegure ikizamini cy’amategeko y’umuhanda ukoresheje ibibazo n’ibyapa.', 'Kuramo kuri Google Play', 'Nyuma yo gushyiramo porogaramu, yifungure maze ufungure konti. Ubutumire bwawe burahita bwemezwa iyo ukoresheje iyi buto.', 'Porogaramu usanzwe uyifite? Ongera ufungure ubutumire nyuma yo kuyishyiramo. Niba bufungukiye muri mushakisha, emerera porogaramu gufungura amahuza mu igenamiterere.', 'Ubu butumire ntibwemewe cyangwa ntibukiboneka. Ushobora gukuramo porogaramu.', 'Ubutumire bukurikirana konti zafunguwe neza. Nta bihembo bitangwa ubu.'],
    ][$language];
    $play = $valid ? ReferralService::playLink($code) : 'https://play.google.com/store/apps/details?id=' . ReferralService::PACKAGE;
    header('Content-Type: text/html; charset=utf-8');
    header('Cache-Control: no-store');
    header('Referrer-Policy: no-referrer');
    header("Content-Security-Policy: default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'");
    http_response_code($valid ? 200 : 404);
    $escape = static function ($value) { return htmlspecialchars($value, ENT_QUOTES, 'UTF-8'); };
    require __DIR__ . '/../views/referral.php';
    exit();
}

function referralAssetLinks($db, $params): void {
    $fingerprints = array_values(array_filter(array_map('trim', explode(',', Env::get('ANDROID_APP_SIGNING_SHA256', ''))),
        static function ($value) { return preg_match('/^(?:[A-Fa-f0-9]{2}:){31}[A-Fa-f0-9]{2}$/D', $value); }));
    header('Content-Type: application/json');
    if (!$fingerprints) {
        http_response_code(503);
        header('Cache-Control: no-store');
        echo '[]';
        exit();
    }
    header('Cache-Control: public, max-age=3600');
    echo json_encode([['relation' => ['delegate_permission/common.handle_all_urls'], 'target' => [
        'namespace' => 'android_app', 'package_name' => ReferralService::PACKAGE,
        'sha256_cert_fingerprints' => $fingerprints,
    ]]], JSON_UNESCAPED_SLASHES);
    exit();
}
