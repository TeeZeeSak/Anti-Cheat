<?php
/** @var array $site */
?>
</main>
<footer class="site-footer">
    <div class="container site-footer__inner">
        <div class="site-footer__brand">
            <span class="site-brand__mark" aria-hidden="true">✦</span>
            <p class="site-footer__name"><?= e($site['name']) ?></p>
            <p class="site-footer__tagline"><?= e($site['tagline']) ?></p>
        </div>
        <div class="site-footer__contact">
            <p><strong>Studio</strong><br><?= e($site['location']) ?></p>
            <p>
                <strong>Booking</strong><br>
                <a href="mailto:<?= e($site['email']) ?>"><?= e($site['email']) ?></a><br>
                <a href="tel:<?= e(preg_replace('/[^+\d]/', '', $site['phone'])) ?>"><?= e($site['phone']) ?></a>
            </p>
            <p>
                <strong>Follow</strong><br>
                <a href="<?= e($site['instagram']) ?>" rel="noopener" target="_blank">Instagram</a>
            </p>
        </div>
    </div>
    <p class="site-footer__legal">
        &copy; <?= date('Y') ?> <?= e($site['name']) ?>. All work shown is original and protected.
    </p>
</footer>
<script src="<?= e(url('assets/js/main.js')) ?>" defer></script>
</body>
</html>
