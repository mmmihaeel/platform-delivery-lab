<?php

declare(strict_types=1);

$rawEvent = stream_get_contents(STDIN);
$event = json_decode($rawEvent ?: '{}', true);

echo json_encode([
    'runtime' => 'php8.3',
    'status' => 'ok',
    'version' => '1.0.0',
    'eventType' => $event['source'] ?? 'unknown',
], JSON_UNESCAPED_SLASHES);
