<?php

declare(strict_types=1);

$service = getenv('SERVICE_NAME') ?: 'php-runtime-api';
$runtime = getenv('SERVICE_RUNTIME') ?: 'php8.3';
$version = getenv('SERVICE_VERSION') ?: '1.0.0';
$environment = getenv('PLATFORM_ENV') ?: 'local';
$hostname = gethostname() ?: 'unknown';
$requestPath = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$segments = array_values(array_filter(explode('/', trim($requestPath, '/'))));
$routeKey = count($segments) > 0 ? $segments[count($segments) - 1] : '';
$routeGroup = count($segments) > 1 ? implode('/', array_slice($segments, 0, -1)) : 'root';

$payload = [
    'service' => $service,
    'runtime' => $runtime,
    'version' => $version,
    'environment' => $environment,
    'hostname' => $hostname,
    'requestPath' => $requestPath,
    'routeGroup' => $routeGroup,
    'forwardedFor' => $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null,
    'forwardedHost' => $_SERVER['HTTP_X_FORWARDED_HOST'] ?? null,
    'forwardedProto' => $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? null,
];

if ($requestPath === '/') {
    respond(200, $payload + [
        'status' => 'ok',
        'endpoints' => ['/healthz', '/status'],
    ]);
}

if ($routeKey === 'healthz') {
    respond(200, $payload + ['status' => 'ok']);
}

if ($routeKey === 'status') {
    respond(200, $payload + [
        'status' => 'ok',
        'diagnostics' => [
            'method' => $_SERVER['REQUEST_METHOD'] ?? 'GET',
            'userAgent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
        ],
    ]);
}

respond(404, $payload + ['status' => 'not_found']);

function respond(int $statusCode, array $payload): void
{
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($payload, JSON_UNESCAPED_SLASHES);
    exit;
}
