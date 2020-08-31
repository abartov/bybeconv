# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@is_clamped = (elid) ->
  el = document.getElementById(elid);
  el.scrollHeight > (el.clientHeight + 5)

