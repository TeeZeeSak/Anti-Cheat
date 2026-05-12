<?php
require __DIR__ . '/includes/config.php';
$pageTitle = 'Contact';
$pageKey = 'contact.php';

session_start();

$flash = $_SESSION['contact_flash'] ?? null;
$old = $_SESSION['contact_old'] ?? [];
unset($_SESSION['contact_flash'], $_SESSION['contact_old']);

if (!isset($_SESSION['contact_token'])) {
    $_SESSION['contact_token'] = bin2hex(random_bytes(32));
}
$token = $_SESSION['contact_token'];

require __DIR__ . '/includes/header.php';
?>
<section class="page-header">
    <div class="container">
        <p class="section__eyebrow">Booking & inquiries</p>
        <h1 class="page-header__title">Let's talk about your next piece.</h1>
        <p class="page-header__lede">Tell me about the idea, placement, and approximate size. I usually
            respond within two business days. For urgent requests, DM on Instagram.</p>
    </div>
</section>

<section class="section">
    <div class="container split split--contact">
        <div class="split__col">
            <?php if ($flash): ?>
                <div class="flash flash--<?= e($flash['type']) ?>" role="status">
                    <?= e($flash['message']) ?>
                </div>
            <?php endif; ?>
            <form class="contact-form" action="<?= e(url('contact-submit.php')) ?>" method="post" novalidate>
                <input type="hidden" name="token" value="<?= e($token) ?>">
                <input type="text" name="website" tabindex="-1" autocomplete="off" class="contact-form__hp" aria-hidden="true">
                <div class="form-row">
                    <label for="name">Name</label>
                    <input type="text" id="name" name="name" required maxlength="120" value="<?= e($old['name'] ?? '') ?>">
                </div>
                <div class="form-row">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" required maxlength="160" value="<?= e($old['email'] ?? '') ?>">
                </div>
                <div class="form-row form-row--split">
                    <div>
                        <label for="placement">Placement</label>
                        <input type="text" id="placement" name="placement" maxlength="120" placeholder="e.g. forearm" value="<?= e($old['placement'] ?? '') ?>">
                    </div>
                    <div>
                        <label for="size">Approx. size</label>
                        <input type="text" id="size" name="size" maxlength="60" placeholder="e.g. 4 x 6 in" value="<?= e($old['size'] ?? '') ?>">
                    </div>
                </div>
                <div class="form-row">
                    <label for="message">Idea</label>
                    <textarea id="message" name="message" rows="6" required maxlength="4000"><?= e($old['message'] ?? '') ?></textarea>
                </div>
                <button type="submit" class="btn btn--primary">Send inquiry</button>
            </form>
        </div>
        <aside class="split__col contact-aside">
            <h2>Studio details</h2>
            <p><strong>By appointment</strong><br><?= e($site['location']) ?></p>
            <p><strong>Email</strong><br><a href="mailto:<?= e($site['email']) ?>"><?= e($site['email']) ?></a></p>
            <p><strong>Phone</strong><br><a href="tel:<?= e(preg_replace('/[^+\d]/', '', $site['phone'])) ?>"><?= e($site['phone']) ?></a></p>
            <p><strong>Instagram</strong><br><a href="<?= e($site['instagram']) ?>" rel="noopener" target="_blank">@<?= e($site['artist']) ?></a></p>
            <p class="contact-aside__hours"><strong>Hours</strong><br>Tue – Sat · 11am – 8pm<br>Closed Sun & Mon</p>
        </aside>
    </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
