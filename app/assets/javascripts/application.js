//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.ui.autocomplete.autoSelect
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

  $(".moreless").click(function() {
     $(".short-bio").hide();
     $(".full-bio").slideDown();
  });
  
  $(".lessmore").click(function() {
     $(".full-bio").slideUp();
     $(".short-bio").show();
  });

  $("#q").select();

});
