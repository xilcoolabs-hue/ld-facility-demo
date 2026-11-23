const menuButton = document.querySelector('.menu-button');
const mainNavigation = document.querySelector('nav[aria-label="Main navigation"]');

if (menuButton && mainNavigation) {
  const mobileNavigation = mainNavigation.cloneNode(true);
  mobileNavigation.id = 'mobile-navigation';
  mobileNavigation.className = 'mobile-nav';
  mobileNavigation.style.display = 'none';
  menuButton.closest('header').append(mobileNavigation);
  menuButton.setAttribute('aria-controls', mobileNavigation.id);

  menuButton.addEventListener('click', () => {
    const opening = menuButton.getAttribute('aria-expanded') === 'false';
    menuButton.setAttribute('aria-expanded', String(opening));
    mobileNavigation.style.display = opening ? '' : 'none';
  });
}

const serviceField = document.querySelector('.enquiry-form select[name="service"]');
const requestedService = new URLSearchParams(location.search).get('service');
if (serviceField && Array.from(serviceField.options).some(option => option.value === requestedService)) {
  serviceField.value = requestedService;
}

const comparisonSlider = document.querySelector('.range-label input[type="range"]');
const beforeImage = document.querySelector('.before-image');
const comparisonLine = document.querySelector('.compare-line');
if (comparisonSlider && beforeImage && comparisonLine) {
  comparisonSlider.addEventListener('input', () => {
    const position = comparisonSlider.value + '%';
    beforeImage.style.width = position;
    comparisonLine.style.left = position;
  });
}
