<?php
require __DIR__ . '/includes/config.php';
$pageTitle = 'Home';
$pageKey = 'index.php';
$featured = array_slice($gallery, 0, 3);
require __DIR__ . '/includes/header.php';
?>
<section class="hero">
    <div class="hero__overlay" aria-hidden="true"></div>
    <div class="container hero__content">
        <p class="hero__eyebrow">Custom tattoo studio · est. <?= (int) date('Y') - (int) $site['years'] ?></p>
        <h1 class="hero__title">Ink that <em>tells</em> your story.</h1>
        <p class="hero__lede"><?= e($site['tagline']) ?></p>
        <div class="hero__cta">
            <a class="btn btn--primary" href="<?= e(url('contact.php')) ?>">Book a consultation</a>
            <a class="btn btn--ghost" href="<?= e(url('gallery.php')) ?>">View the gallery</a>
        </div>
    </div>
</section>

<section class="section">
    <div class="container section__intro">
        <p class="section__eyebrow">Recent work</p>
        <h2 class="section__title">Pieces fresh off the needle</h2>
        <p class="section__lede">A glimpse at the latest custom designs. See more in the full gallery.</p>
    </div>
    <div class="container gallery-grid gallery-grid--featured">
        <?php foreach ($featured as $piece): ?>
            <figure class="gallery-card">
                <img src="<?= e(url($piece['image'])) ?>" alt="<?= e($piece['title']) ?>" loading="lazy">
                <figcaption>
                    <span class="gallery-card__title"><?= e($piece['title']) ?></span>
                    <span class="gallery-card__tags"><?= e(implode(' · ', $piece['tags'])) ?></span>
                </figcaption>
            </figure>
        <?php endforeach; ?>
    </div>
    <p class="section__cta">
        <a class="link-arrow" href="<?= e(url('gallery.php')) ?>">See the full gallery <span aria-hidden="true">→</span></a>
    </p>
</section>

<section class="section section--alt">
    <div class="container split">
        <div class="split__col">
            <p class="section__eyebrow">The studio</p>
            <h2 class="section__title">A private space for permanent art.</h2>
            <p>Every booking is one-on-one. No walk-in chaos, no rush — just clean lines, careful design,
                and a process that respects the skin you're trusting me with.</p>
            <p>From a first-tattoo single-needle script to a full sleeve cover-up, every piece starts with
                a conversation about <em>what it means</em>, then a custom drawing built around your body.</p>
            <a class="btn btn--ghost" href="<?= e(url('about.php')) ?>">More about the artist</a>
        </div>
        <ul class="split__col stat-list">
            <li><span class="stat-list__num"><?= (int) $site['years'] ?>+</span><span class="stat-list__label">years tattooing</span></li>
            <li><span class="stat-list__num">600+</span><span class="stat-list__label">healed pieces</span></li>
            <li><span class="stat-list__num">100%</span><span class="stat-list__label">custom designs</span></li>
        </ul>
    </div>
</section>

<section class="section">
    <div class="container section__intro">
        <p class="section__eyebrow">What I do</p>
        <h2 class="section__title">Specialties</h2>
    </div>
    <div class="container service-grid">
        <?php foreach (array_slice($services, 0, 3) as $service): ?>
            <article class="service-card">
                <h3><?= e($service['title']) ?></h3>
                <p><?= e($service['description']) ?></p>
                <p class="service-card__price">From <?= e($site['currency']) ?><?= (int) $service['price_from'] ?></p>
            </article>
        <?php endforeach; ?>
    </div>
    <p class="section__cta">
        <a class="link-arrow" href="<?= e(url('services.php')) ?>">All services & rates <span aria-hidden="true">→</span></a>
    </p>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
