import $ from 'jquery';

const initRadioBtnForResultDisplay = () => {
  $(document).on('change', 'input:radio[id="topResultDisplay"]', function (event) {
    $().button('toggle');
    $('#cheapestRateBlock').toggleClass('d-none');
    $('#allResultsBlock').toggleClass('d-none');
  });
  $(document).on('change', 'input:radio[id="allResultsDisplay"]', function (event) {
    $().button('toggle');
    $('#cheapestRateBlock').toggleClass('d-none');
    $('#allResultsBlock').toggleClass('d-none');
  });
};

export { initRadioBtnForResultDisplay };