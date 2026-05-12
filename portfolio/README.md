# HookahCast Tattoo Portfolio

A small, self-contained PHP/HTML portfolio site for a tattoo artist. No
framework, no build step — drop it on any host with PHP 7.4+ and it runs.

## Layout

```
portfolio/
├── index.php          # Landing page (hero, featured work, intro)
├── about.php          # Bio + studio process
├── gallery.php        # Filterable gallery
├── services.php       # Services, rates, studio policies
├── contact.php        # Contact form (CSRF + honeypot protected)
├── contact-submit.php # Form handler (logs to data/, optional mail())
├── includes/
│   ├── config.php     # Site config: artist info, gallery, services
│   ├── header.php     # Shared header / nav
│   └── footer.php     # Shared footer
├── assets/
│   ├── css/styles.css
│   ├── js/main.js     # Nav toggle + gallery filter
│   └── images/        # Placeholder SVGs — replace with real photos
└── data/              # Local form-submission log (gitignored)
```

## Local preview

```bash
cd portfolio
php -S 127.0.0.1:8000
```

Then open <http://127.0.0.1:8000>.

## Customizing

Open [`includes/config.php`](includes/config.php) to update:

- `$site` — artist name, contact details, Instagram link, years experience.
- `$gallery` — array of pieces with `title`, `image`, and `tags`.
- `$services` — list of services with `title`, `description`, `price_from`.

Drop real photos into `assets/images/` and reference them from `$gallery`.

## Contact form

Submissions are appended as JSON Lines to `data/contact-submissions.log`
(gitignored). If the host has `mail()` available, the handler also fires a
best-effort email to `$site['email']` — failures are non-fatal.

The form is protected by:

- A per-session CSRF token validated with `hash_equals`.
- A hidden honeypot field (`website`) that silently drops bot submissions.
- Server-side length and format validation.
