(function () {
    'use strict';

    // Mobile nav toggle.
    const toggle = document.querySelector('.nav-toggle');
    const nav = document.getElementById('primary-nav');
    if (toggle && nav) {
        toggle.addEventListener('click', function () {
            const open = nav.classList.toggle('is-open');
            toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });
    }

    // Gallery filtering.
    const galleryGrid = document.getElementById('gallery');
    if (galleryGrid) {
        const cards = Array.from(galleryGrid.querySelectorAll('.gallery-card'));
        const chips = Array.from(document.querySelectorAll('.filter-bar__chip'));
        const empty = document.getElementById('gallery-empty');

        const applyFilter = function (filter) {
            let visible = 0;
            cards.forEach(function (card) {
                const tags = (card.dataset.tags || '').split(/\s+/);
                const match = filter === 'all' || tags.indexOf(filter) !== -1;
                card.hidden = !match;
                if (match) {
                    visible += 1;
                }
            });
            if (empty) {
                empty.hidden = visible !== 0;
            }
        };

        chips.forEach(function (chip) {
            chip.addEventListener('click', function () {
                chips.forEach(function (other) { other.classList.remove('is-active'); });
                chip.classList.add('is-active');
                applyFilter(chip.dataset.filter || 'all');
            });
        });
    }
})();
