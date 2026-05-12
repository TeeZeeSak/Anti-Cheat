<?php
require __DIR__ . '/includes/config.php';
$pageTitle = 'Gallery';
$pageKey = 'gallery.php';

$tags = [];
foreach ($gallery as $piece) {
    foreach ($piece['tags'] as $tag) {
        $tags[$tag] = true;
    }
}
$tags = array_keys($tags);
sort($tags);

require __DIR__ . '/includes/header.php';
?>
<section class="page-header">
    <div class="container">
        <p class="section__eyebrow">Portfolio</p>
        <h1 class="page-header__title">Gallery</h1>
        <p class="page-header__lede">A selection of healed and fresh work. Filter by style to narrow it down.</p>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="filter-bar" role="toolbar" aria-label="Filter gallery by tag">
            <button type="button" class="filter-bar__chip is-active" data-filter="all">All</button>
            <?php foreach ($tags as $tag): ?>
                <button type="button" class="filter-bar__chip" data-filter="<?= e($tag) ?>"><?= e(ucwords(str_replace('-', ' ', $tag))) ?></button>
            <?php endforeach; ?>
        </div>
        <div class="gallery-grid" id="gallery">
            <?php foreach ($gallery as $piece): ?>
                <figure class="gallery-card" data-tags="<?= e(implode(' ', $piece['tags'])) ?>">
                    <img src="<?= e(url($piece['image'])) ?>" alt="<?= e($piece['title']) ?>" loading="lazy">
                    <figcaption>
                        <span class="gallery-card__title"><?= e($piece['title']) ?></span>
                        <span class="gallery-card__tags"><?= e(implode(' · ', $piece['tags'])) ?></span>
                    </figcaption>
                </figure>
            <?php endforeach; ?>
        </div>
        <p class="gallery-empty" id="gallery-empty" hidden>No pieces match that filter yet — check back soon.</p>
    </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
