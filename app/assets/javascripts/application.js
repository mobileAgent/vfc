//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.ui.autocomplete.autoSelect
//= require jquery.grab.js
//= require jquery.transform.js
//= require jquery.jplayer.js
//= require mod.csstransforms.min.js
//= require jquery.truncator.js
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
