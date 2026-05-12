<?php
require __DIR__ . '/includes/config.php';
$pageTitle = 'Services';
$pageKey = 'services.php';
require __DIR__ . '/includes/header.php';
?>
<section class="page-header">
    <div class="container">
        <p class="section__eyebrow">Services & rates</p>
        <h1 class="page-header__title">What I work on.</h1>
        <p class="page-header__lede">Starting rates only — final pricing depends on size, placement, and detail.
            A custom quote is provided after the first consultation.</p>
    </div>
</section>

<section class="section">
    <div class="container service-grid service-grid--full">
        <?php foreach ($services as $service): ?>
            <article class="service-card">
                <h2><?= e($service['title']) ?></h2>
                <p><?= e($service['description']) ?></p>
                <p class="service-card__price">From <?= e($site['currency']) ?><?= (int) $service['price_from'] ?></p>
            </article>
        <?php endforeach; ?>
    </div>
</section>

<section class="section section--alt">
    <div class="container">
        <p class="section__eyebrow">Good to know</p>
        <h2 class="section__title">Studio policies</h2>
        <dl class="policy-list">
            <div>
                <dt>Deposits</dt>
                <dd>A non-refundable deposit of <?= e($site['currency']) ?>80 secures your appointment
                    and is applied to the final price.</dd>
            </div>
            <div>
                <dt>Rescheduling</dt>
                <dd>Reschedule once at no cost with at least 72 hours notice. Same-day cancellations
                    forfeit the deposit.</dd>
            </div>
            <div>
                <dt>Age & ID</dt>
                <dd>18+ with valid government-issued ID. No exceptions.</dd>
            </div>
            <div>
                <dt>Health</dt>
                <dd>Please disclose any conditions (pregnancy, blood thinners, recent vaccinations)
                    before the appointment so we can plan safely.</dd>
            </div>
        </dl>
    </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
