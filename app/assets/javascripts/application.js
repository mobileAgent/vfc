//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.ui.autocomplete.autoSelect
//= require jquery.grab
//= require jquery.transform
//= require jquery.jplayer
//= require mod.csstransforms.min
//= require jquery.truncator
//= require_self
//= require_tree .

$(document).ready(function() {
  $("#q").autocomplete({
    source: '/welcome/search',
    minLength: 2,
    selectFirst: true,
    select: function(event,ui) {
       $("#q").val(ui.item.value);
       $("#sform").submit();
       }        
  });

  $(function() {
     $('.bio').truncate({max_length: 500});
  });
    
  $("#q").select();

});
