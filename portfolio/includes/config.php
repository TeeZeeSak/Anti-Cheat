<?php
/**
 * Site configuration for the HookahCast tattoo portfolio.
 *
 * Edit these values to customize the site without touching templates.
 */

$site = [
    'name'        => 'HookahCast Ink',
    'tagline'     => 'Custom tattoo artistry — bold lines, deep shadows, lasting stories.',
    'artist'      => 'HookahCast',
    'location'    => 'Studio by appointment',
    'email'       => 'studio@hookahcast.ink',
    'phone'       => '+1 (555) 010-2040',
    'instagram'   => 'https://instagram.com/hookahcast',
    'years'       => 8,
    'currency'    => '$',
];

$nav = [
    'index.php'    => 'Home',
    'about.php'    => 'About',
    'gallery.php'  => 'Gallery',
    'services.php' => 'Services',
    'contact.php'  => 'Contact',
];

/**
 * Curated gallery items. Replace the `image` paths with real photos
 * inside `assets/images/`. Each item supports optional `tags` for filtering.
 */
$gallery = [
    ['title' => 'Black Sun',         'image' => 'assets/images/sample-1.svg', 'tags' => ['blackwork', 'arm']],
    ['title' => 'Serpent & Rose',    'image' => 'assets/images/sample-2.svg', 'tags' => ['neo-traditional', 'arm']],
    ['title' => 'Mountain Sleeve',   'image' => 'assets/images/sample-3.svg', 'tags' => ['blackwork', 'sleeve']],
    ['title' => 'Geometric Wolf',    'image' => 'assets/images/sample-4.svg', 'tags' => ['geometric', 'chest']],
    ['title' => 'Lotus Mandala',     'image' => 'assets/images/sample-5.svg', 'tags' => ['fineline', 'back']],
    ['title' => 'Reaper Hand',       'image' => 'assets/images/sample-6.svg', 'tags' => ['blackwork', 'hand']],
    ['title' => 'Koi in Motion',     'image' => 'assets/images/sample-7.svg', 'tags' => ['neo-traditional', 'leg']],
    ['title' => 'Ocean Lines',       'image' => 'assets/images/sample-8.svg', 'tags' => ['fineline', 'forearm']],
    ['title' => 'Crow & Lantern',    'image' => 'assets/images/sample-9.svg', 'tags' => ['blackwork', 'thigh']],
];

$services = [
    [
        'title'       => 'Custom Design',
        'description' => 'Bespoke artwork drawn for you from scratch — sketch consultations included.',
        'price_from'  => 180,
    ],
    [
        'title'       => 'Cover-ups & Reworks',
        'description' => 'Transform old or unwanted tattoos into pieces you wear with pride.',
        'price_from'  => 220,
    ],
    [
        'title'       => 'Fine Line & Single Needle',
        'description' => 'Delicate, intricate work for minimalist and lettering pieces.',
        'price_from'  => 150,
    ],
    [
        'title'       => 'Black & Grey Realism',
        'description' => 'High-contrast shading, portrait work, and photo-real detail.',
        'price_from'  => 250,
    ],
    [
        'title'       => 'Neo-Traditional',
        'description' => 'Bold outlines, dimensional color, and modern takes on classic motifs.',
        'price_from'  => 200,
    ],
    [
        'title'       => 'Flash Day',
        'description' => 'Walk-in friendly flash sheets at a fixed rate. Follow Instagram for dates.',
        'price_from'  => 120,
    ],
];

/**
 * Return the absolute filesystem path for the portfolio root.
 */
function portfolio_root(): string
{
    return dirname(__DIR__);
}

/**
 * Build a URL relative to the portfolio root, taking BASE_PATH into account
 * when the site is served from a subdirectory.
 */
function url(string $path): string
{
    $base = rtrim((string) ($GLOBALS['BASE_PATH'] ?? ''), '/');
    return $base . '/' . ltrim($path, '/');
}

/**
 * HTML-escape helper to avoid repeating htmlspecialchars everywhere.
 */
function e(?string $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}
