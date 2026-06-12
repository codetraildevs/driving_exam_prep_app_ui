<?php
/**
 * Pricing route handlers.
 */

function getPricingPlans($conn, $params): void
{
    $language = SecurityUtils::sanitizeString($_GET['language'] ?? 'rw');

    if ($language === 'rw') {
        $plans = [
            ['tier' => '1_MONTH',  'durationDays' => 30,  'price' => 1500,  'label' => '1 Month'],
            ['tier' => '3_MONTHS', 'durationDays' => 90,  'price' => 3000,  'label' => '3 Months'],
            ['tier' => '6_MONTHS', 'durationDays' => 180, 'price' => 5000,  'label' => '6 Months'],
        ];
    } else {
        $plans = [
            ['tier' => '1_MONTH',  'durationDays' => 30,  'price' => 3000,  'label' => '1 Month'],
            ['tier' => '3_MONTHS', 'durationDays' => 90,  'price' => 5000,  'label' => '3 Months'],
            ['tier' => '6_MONTHS', 'durationDays' => 180, 'price' => 10000, 'label' => '6 Months'],
        ];
    }

    respond([
        'language' => $language,
        'currency' => 'RWF',
        'plans'    => $plans,
    ], 200);
}
