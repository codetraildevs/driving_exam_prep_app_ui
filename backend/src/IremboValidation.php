<?php
/** Shared contract for the Irembo service-request module. No external integration. */
final class IremboValidation
{
    public const DISTRICTS = ['Bugesera','Gasabo','Gicumbi','Gisagara','Huye','Karongi','Kayonza','Kicukiro','Kirehe','Muhanga','Musanze','Ngoma','Ngororero','Nyagatare','Nyamagabe','Nyamasheke','Nyanza','Nyarugenge','Nyaruguru','Rubavu','Ruhango','Rusizi','Rutsiro','Rwamagana'];
    public const STATUSES = ['Pending','In Review','Needs Information','Completed','Rejected','Cancelled'];
    public static function text(array $input, string $key, int $max, bool $required = true): ?string {
        $v = $input[$key] ?? null;
        if ($v === null || $v === '') {
            if ($required) throw new InvalidArgumentException($key);
            return null;
        }
        if (!is_string($v)) throw new InvalidArgumentException($key);
        $v = trim($v);
        if (($required && $v === '') || preg_match_all('/./us', $v) > $max || preg_match(in_array($key, ['reason','internalNote','applicantMessage'], true) ? '/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/' : '/[\x00-\x1F\x7F]/', $v)) throw new InvalidArgumentException($key);
        return $v === '' ? null : $v;
    }
    public static function date($value, string $field): string {
        if (!is_string($value)) throw new InvalidArgumentException($field);
        $date = DateTimeImmutable::createFromFormat('!Y-m-d', $value);
        if (!$date || $date->format('Y-m-d') !== $value) throw new InvalidArgumentException($field);
        return $value;
    }
    public static function nationalId(string $value): string {
        if (!preg_match('/^[0-9]{16}$/D', $value)) throw new InvalidArgumentException('nationalId');
        return $value;
    }
    public static function registration(array $input): array {
        $out = [];
        $out['fullName'] = self::text($input, 'fullName', 150);
        $phone = self::text($input, 'phoneNumber', 20);
        $phone = SecurityUtils::normalizePhone($phone);
        if (!preg_match('/^07[2389][0-9]{7}$/D', $phone)) throw new InvalidArgumentException('phoneNumber');
        $out['phoneNumber'] = $phone;
        $out['nationalId'] = self::nationalId(self::text($input, 'nationalId', 32));
        $out['dob'] = self::date($input['dob'] ?? null, 'dob');
        if ($out['dob'] > date('Y-m-d')) throw new InvalidArgumentException('dob');
        $out['service'] = self::text($input, 'service', 20);
        if (!in_array($out['service'], ['Provisoire','Permis'], true)) throw new InvalidArgumentException('service');
        $out['permisOption'] = $out['category'] = $out['provisoireCode'] = null;
        if ($out['service'] === 'Permis') {
            $out['permisOption'] = self::text($input, 'permisOption', 20);
            if (!in_array($out['permisOption'], ['Manual','Automatic'], true)) throw new InvalidArgumentException('permisOption');
            $out['provisoireCode'] = self::text($input, 'provisoireCode', 80);
            if ($out['permisOption'] === 'Automatic') {
                if (isset($input['category']) && (!is_string($input['category']) || strtoupper(trim($input['category'])) !== 'A')) throw new InvalidArgumentException('category');
                $out['category'] = 'A';
            } else {
                $out['category'] = strtoupper(self::text($input, 'category', 10));
                if (!in_array($out['category'], ['A','B','F'], true)) throw new InvalidArgumentException('category');
            }
        }
        $out['examLanguage'] = self::text($input, 'examLanguage', 2);
        if (!in_array($out['examLanguage'], ['rw','en','fr'], true)) throw new InvalidArgumentException('examLanguage');
        $out['district'] = self::text($input, 'district', 40);
        if (!in_array($out['district'], self::DISTRICTS, true)) throw new InvalidArgumentException('district');
        $preferredDate = $input['preferredExamDate'] ?? null;
        $out['preferredExamDate'] = $preferredDate === null || $preferredDate === '' ? null : self::date($preferredDate, 'preferredExamDate');
        return $out;
    }
}
