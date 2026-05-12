<?php
require __DIR__ . '/includes/config.php';

session_start();

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Location: ' . url('contact.php'));
    exit;
}

$expectedToken = $_SESSION['contact_token'] ?? null;
$submittedToken = $_POST['token'] ?? '';
if (!$expectedToken || !hash_equals($expectedToken, (string) $submittedToken)) {
    $_SESSION['contact_flash'] = ['type' => 'error', 'message' => 'Session expired. Please try again.'];
    header('Location: ' . url('contact.php'));
    exit;
}

// Honeypot — silently accept and discard bot submissions.
if (!empty($_POST['website'])) {
    unset($_SESSION['contact_token']);
    $_SESSION['contact_flash'] = ['type' => 'success', 'message' => 'Thanks — your message is on its way.'];
    header('Location: ' . url('contact.php'));
    exit;
}

$fields = [
    'name'      => trim((string) ($_POST['name'] ?? '')),
    'email'     => trim((string) ($_POST['email'] ?? '')),
    'placement' => trim((string) ($_POST['placement'] ?? '')),
    'size'      => trim((string) ($_POST['size'] ?? '')),
    'message'   => trim((string) ($_POST['message'] ?? '')),
];

$errors = [];
if ($fields['name'] === '' || strlen($fields['name']) > 120) {
    $errors[] = 'Please share a name (up to 120 characters).';
}
if ($fields['email'] === '' || !filter_var($fields['email'], FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'Please provide a valid email address.';
}
if ($fields['message'] === '' || strlen($fields['message']) > 4000) {
    $errors[] = 'Please describe your idea (up to 4000 characters).';
}

if ($errors) {
    $_SESSION['contact_old'] = $fields;
    $_SESSION['contact_flash'] = ['type' => 'error', 'message' => implode(' ', $errors)];
    header('Location: ' . url('contact.php'));
    exit;
}

$entry = $fields + [
    'submitted_at' => date('c'),
    'ip'           => $_SERVER['REMOTE_ADDR'] ?? null,
    'user_agent'   => substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 240),
];

$dataDir = portfolio_root() . '/data';
if (!is_dir($dataDir)) {
    @mkdir($dataDir, 0775, true);
}
$logFile = $dataDir . '/contact-submissions.log';
@file_put_contents($logFile, json_encode($entry, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . PHP_EOL, FILE_APPEND | LOCK_EX);

// Best-effort email notification. Failures are non-fatal — the entry is still logged.
$to = $site['email'];
$subject = sprintf('[%s] New booking inquiry from %s', $site['name'], $fields['name']);
$body = "Name: {$fields['name']}\n"
      . "Email: {$fields['email']}\n"
      . "Placement: {$fields['placement']}\n"
      . "Size: {$fields['size']}\n"
      . "\nMessage:\n{$fields['message']}\n";
$headers = 'From: ' . $site['email'] . "\r\n"
         . 'Reply-To: ' . $fields['email'] . "\r\n"
         . 'X-Mailer: PHP/' . phpversion();
if (function_exists('mail')) {
    @mail($to, $subject, $body, $headers);
}

unset($_SESSION['contact_token']);
$_SESSION['contact_flash'] = [
    'type' => 'success',
    'message' => 'Thanks ' . $fields['name'] . ' — your inquiry is in. I\'ll reply within two business days.',
];
header('Location: ' . url('contact.php'));
exit;
