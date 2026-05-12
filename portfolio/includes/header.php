<?php
/** @var array $site */
/** @var array $nav */
/** @var string $pageTitle */
/** @var string $pageKey */

$currentScript = basename($_SERVER['SCRIPT_NAME'] ?? 'index.php');
$activeKey = $pageKey ?? $currentScript;
?><!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($pageTitle ?? $site['name']) ?> — <?= e($site['name']) ?></title>
    <meta name="description" content="<?= e($site['tagline']) ?>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@500;700&family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= e(url('assets/css/styles.css')) ?>">
</head>
<body class="page-<?= e(pathinfo($activeKey, PATHINFO_FILENAME)) ?>">
<a class="skip-link" href="#main">Skip to content</a>
<header class="site-header">
    <div class="container site-header__inner">
        <a class="site-brand" href="<?= e(url('index.php')) ?>">
            <span class="site-brand__mark" aria-hidden="true">✦</span>
            <span class="site-brand__text">
                <span class="site-brand__name"><?= e($site['name']) ?></span>
                <span class="site-brand__tagline">Custom Tattoo Studio</span>
            </span>
        </a>
        <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="primary-nav" aria-label="Toggle navigation">
            <span></span><span></span><span></span>
        </button>
        <nav class="site-nav" id="primary-nav" aria-label="Primary">
            <ul>
                <?php foreach ($nav as $href => $label): ?>
                    <li>
                        <a href="<?= e(url($href)) ?>"<?= $href === $activeKey ? ' aria-current="page"' : '' ?>>
                            <?= e($label) ?>
                        </a>
                    </li>
                <?php endforeach; ?>
            </ul>
        </nav>
    </div>
</header>
<main id="main">
