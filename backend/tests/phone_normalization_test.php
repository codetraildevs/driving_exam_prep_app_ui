<?php
require_once __DIR__ . '/../src/SecurityUtils.php';
$cases = [
    '0739914099' => '0739914099',
    '+250739914099' => '0739914099',
    '250739914099' => '0739914099',
    '739914099' => '0739914099',
    '(+250) 739-914-099' => '0739914099',
    '+250787012615' => '0787012615',
    '+33123456789' => '+33123456789',
];
foreach ($cases as $input => $expected) {
    $actual = SecurityUtils::normalizePhone((string)$input);
    if ($actual !== $expected) throw new RuntimeException("Unexpected normalization for $input");
}
echo "Phone normalization cases passed.\n";
