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
//= require ahoy
//= require rails.validations

//= require_tree .

var mobileWidth = 767;

function isMobile() {
  return window.innerWidth < mobileWidth;
}
