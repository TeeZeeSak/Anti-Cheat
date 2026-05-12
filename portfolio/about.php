<?php
require __DIR__ . '/includes/config.php';
$pageTitle = 'About';
$pageKey = 'about.php';
require __DIR__ . '/includes/header.php';
?>
<section class="page-header">
    <div class="container">
        <p class="section__eyebrow">About the artist</p>
        <h1 class="page-header__title">Hand-drawn ink, by <?= e($site['artist']) ?>.</h1>
    </div>
</section>

<section class="section">
    <div class="container split split--portrait">
        <div class="split__col split__col--media">
            <div class="portrait-frame" aria-hidden="true">
                <span class="portrait-frame__mark">✦</span>
            </div>
        </div>
        <div class="split__col">
            <p>Tattooing for over <?= (int) $site['years'] ?> years out of a private studio.
                Trained in traditional flash, sharpened on blackwork and fine-line, and never short
                on coffee or stencil paper.</p>
            <p>My work lives at the intersection of <strong>bold</strong> and <strong>delicate</strong>:
                heavy black foundations carrying intricate, almost botanical detail. I draw every
                design from scratch, treat each appointment as a collaboration, and won't put
                a needle to skin until both of us love what's on the paper.</p>
            <p>Studio practices follow all bloodborne pathogen and cross-contamination standards.
                Single-use needles, disposable tube setups, hospital-grade barrier film on every
                surface, and an autoclave-sterilized workstation between every client.</p>
        </div>
    </div>
</section>

<section class="section section--alt">
    <div class="container">
        <p class="section__eyebrow">Process</p>
        <h2 class="section__title">From idea to ink.</h2>
        <ol class="process-list">
            <li>
                <span class="process-list__num">01</span>
                <h3>Consultation</h3>
                <p>We talk through your idea, references, placement, and budget — either in person
                    or over a video call. No pressure, no upsell.</p>
            </li>
            <li>
                <span class="process-list__num">02</span>
                <h3>Custom design</h3>
                <p>I draw the piece from scratch and share previews. Revisions are part of the
                    deal — your skin, your story.</p>
            </li>
            <li>
                <span class="process-list__num">03</span>
                <h3>Tattoo day</h3>
                <p>A clean, quiet studio. Bring snacks, headphones, and someone you trust if you'd
                    like company. I'll handle the rest.</p>
            </li>
            <li>
                <span class="process-list__num">04</span>
                <h3>Aftercare</h3>
                <p>You'll leave with detailed instructions and a follow-up message a week later.
                    Touch-ups within six months are on the house.</p>
            </li>
        </ol>
    </div>
</section>

<?php require __DIR__ . '/includes/footer.php'; ?>
