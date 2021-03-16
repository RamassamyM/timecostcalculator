import Typed from 'typed.js';

const loadDynamicBannerText = () => {
  new Typed('#banner-typed-text', {
    strings: ["Calculate cost and time", "Optimize shipping purchases"],
    typeSpeed: 40,
    loop: true
  });
}

export { loadDynamicBannerText };