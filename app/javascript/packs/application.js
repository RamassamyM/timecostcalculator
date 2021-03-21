// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)


// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

// Internal imports, e.g:
import { initUpdateNavbarOnScroll } from '../components/navbar';
import { loadDynamicBannerText } from '../components/banner';
import { initSelect2 } from '../components/select2';
import { initTable } from '../components/table';
// import '../components/tableExport'
// import '../components/bootstrapTableExport'

const images = require.context('../images', true)

document.addEventListener('turbolinks:load', () => {
  loadDynamicBannerText();
  // Call your functions here, e.g:
  // initSelect2();
  initUpdateNavbarOnScroll();
  initSelect2();
  initTable();
});

require("trix")
require("@rails/actiontext")