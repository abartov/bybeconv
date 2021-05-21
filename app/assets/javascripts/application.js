// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.slick
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
//= require jquery.mark.min
//= require jquery.caret
//= require wikidata-sdk.min
//= require activestorage
//= require moment
//= require moment/he.js
//= require tempusdominus-bootstrap-4
//= require_tree .

var mobileWidth = 767;

function submit_filters() {
  startModal('spinnerdiv');
  if(window.innerWidth < mobileWidth) {
    alert('submitting mobile filters!');
    window.history.replaceState($('#mobile_filters').serialize(), null, '/works');
    $('#mobile_filters').submit();
  } else {
    alert('submitting desktop filters!')
    window.history.replaceState($('#works_filters').serialize(), null, '/works');
    $('#works_filters').submit();
  }
}
