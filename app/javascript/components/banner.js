import Typed from 'typed.js';

const loadDynamicBannerText = () => {
  if (window.location.pathname === '/') {
    new Typed('#banner-typed-text', {
      strings: ["Calculate Shipping Costs.", "Estimate Transit Times."],
      typeSpeed: 40,
      loop: true
    });
  }
}

export { loadDynamicBannerText };
