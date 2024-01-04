<?php

// copied manually & hosted on https://proxmox.nydus.app/glutenfree/webhook.php

if ($_GET['password'] != grab the value from .env) {
    http_response_code(401);
    return;
}

const json_file = __DIR__ . '/webhook.json';

$json = file_exists(json_file) ? json_decode(file_get_contents(json_file), true) : [];

if ($_GET['add']) {
    if (!in_array($_GET['add'], $json)) {
        $json[] = $_GET['add'];
        file_put_contents(json_file, json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
    }

    http_response_code(204);
    return;
}

header("Content-Type: application/json");
echo json_encode($json);
