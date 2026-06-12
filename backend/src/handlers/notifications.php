<?php
/**
 * Notification route handlers (stubs).
 */

function getNotifications($conn, $params): void
{
    global $tokenData;

    respond(['message' => 'Notifications endpoint', 'userId' => $tokenData['userId']], 200);
}

function createNotification($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    respond(['message' => 'Notification created'], 201);
}
