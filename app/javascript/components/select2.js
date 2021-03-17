import $ from 'jquery';
import 'select2';

const initSelect2 = () => {
  jQuery(function() {
    $('.select2').select2({
      maximumSelectionLength: 3,
    });
    $('.select2').val('');
    $('.select2').trigger('change');
    $('.select2_for_place_of_delivery').select2({
      disabled: true,
      maximumSelectionLength: 3,
    });
  })
};

export { initSelect2 };