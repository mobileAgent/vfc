$(document).ready(function() {
  $("#q").autocomplete({
    source: '/welcome/search',
    minLength: 2,
    selectFirst: true,
    select: function(event, ui) {
      $("#q").val(ui.item.value);
      $("#sform").submit();
    }
  });

  $(".moreless").click(function() {
     $(".short-bio").hide();
     $(".full-bio").slideDown();
  });
  
  $(".lessmore").click(function() {
     $(".full-bio").hide();
     $(".short-bio").slideDown();
  });
});