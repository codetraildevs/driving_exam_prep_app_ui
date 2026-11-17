<?php

/** users.createdAt is a timezone-less DATETIME written by PHP date(). */
final class UserRegistrationTime
{
    public static function storageZone(): DateTimeZone {
        // Preserve the existing PHP clock unless the historical storage zone
        // is explicitly configured. Never blindly shift existing DB rows.
        return new DateTimeZone(Env::get('USER_REGISTRATION_TIMEZONE', date_default_timezone_get()));
    }

    public static function now(): string {
        return (new DateTimeImmutable('now', self::storageZone()))->format('Y-m-d H:i:s');
    }

    public static function toKigali($value): ?string {
        if (!is_string($value) || $value === '' || substr($value, 0, 10) === '0000-00-00') return null;
        try {
            return (new DateTimeImmutable($value, self::storageZone()))
                ->setTimezone(new DateTimeZone('Africa/Kigali'))->format(DateTimeInterface::ATOM);
        } catch (Exception $e) {
            return null;
        }
    }

    public static function dayBoundary(string $date, bool $nextDay = false): string {
        $day = DateTimeImmutable::createFromFormat('!Y-m-d', $date, new DateTimeZone('Africa/Kigali'));
        if (!$day || $day->format('Y-m-d') !== $date) throw new InvalidArgumentException('Invalid date');
        if ($nextDay) $day = $day->modify('+1 day');
        return $day->setTimezone(self::storageZone())->format('Y-m-d H:i:s');
    }
}
