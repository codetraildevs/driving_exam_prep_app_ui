<?php

final class ReferralService
{
    public const ORIGIN = 'https://backendapi.rwandatraffic.rw';
    public const PACKAGE = 'com.trafficrules.rwanda.app';

    public static function query($db, string $sql, array $values = []) {
        $stmt = $db->prepare($sql);
        if (!$stmt || !$stmt->execute($values)) throw new RuntimeException('Referral storage unavailable');
        return $stmt;
    }

    public static function validCode($code): bool {
        return is_string($code) && preg_match('/^RW[A-F0-9]{16}$/D', $code) === 1;
    }

    public static function key($key): ?string {
        return is_string($key) && preg_match('/^[a-f0-9]{64}$/D', $key) === 1 ? hash('sha256', $key) : null;
    }

    public static function payloadHash(array $fields, $code): string {
        return hash('sha256', json_encode([$fields, is_string($code) ? $code : null], JSON_UNESCAPED_UNICODE));
    }

    // Caller holds the user's row lock, or has just inserted the new user.
    public static function ensureCode($db, string $userId): string {
        $row = self::query($db, 'SELECT code FROM referral_codes WHERE userId = ?', [$userId])->fetch(PDO::FETCH_ASSOC);
        if ($row) return $row['code'];
        for ($attempt = 0; $attempt < 5; $attempt++) {
            $code = 'RW' . strtoupper(bin2hex(random_bytes(8)));
            try {
                self::query($db, 'INSERT INTO referral_codes (userId, code) VALUES (?, ?)', [$userId, $code]);
                return $code;
            } catch (Throwable $e) {
                // Only retry a random-code collision; never hide other failures.
                if (!self::query($db, 'SELECT userId FROM referral_codes WHERE code = ?', [$code])->fetch(PDO::FETCH_ASSOC)) throw $e;
            }
        }
        throw new RuntimeException('Unable to allocate referral code');
    }

    public static function receipt($db, ?string $keyHash, string $payloadHash): ?array {
        if ($keyHash === null) return null;
        $row = self::query($db,
            'SELECT r.*, u.fullName, u.phoneNumber, u.role, u.isActive FROM referral_registration_receipts r JOIN users u ON u.id = r.userId WHERE r.keyHash = ?',
            [$keyHash])->fetch(PDO::FETCH_ASSOC);
        if (!$row) return null;
        if (!hash_equals($row['payloadHash'], $payloadHash) || !$row['isActive'] || strtotime($row['createdAt']) < time() - 86400) {
            throw new DomainException('REGISTRATION_RETRY_REJECTED');
        }
        return $row;
    }

    // Call ONLY within the transaction that inserts the new account. There is
    // intentionally no public endpoint that attaches referrals to existing users.
    public static function attributeNewAccount($db, string $id, string $device, $code): string {
        if ($code === null || $code === '') return 'none';
        if (!self::validCode($code)) return 'rejected';
        $inviter = self::query($db,
            'SELECT u.id, u.deviceId FROM referral_codes c JOIN users u ON u.id = c.userId WHERE c.code = ? AND u.isActive = 1',
            [$code])->fetch(PDO::FETCH_ASSOC);
        if (!$inviter || $inviter['id'] === $id || $inviter['deviceId'] === $device) return 'rejected';
        self::query($db,
            'INSERT INTO referrals (id, referrerId, referredUserId, code) VALUES (?, ?, ?, ?)',
            [generateUUID(), $inviter['id'], $id, $code]);
        return 'confirmed';
    }

    public static function invitation(string $code): string {
        return self::ORIGIN . '/referral?code=' . rawurlencode($code);
    }

    public static function playLink(string $code): string {
        return 'https://play.google.com/store/apps/details?id=' . self::PACKAGE
            . '&referrer=' . rawurlencode(http_build_query(['referral_code' => $code]));
    }
}
