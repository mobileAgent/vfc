//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery-corner
//= require jquery.ui.autocomplete.autoSelect
//= require jquery.grab
//= require jquery.transform
//= require mod.csstransforms.min
//= require jquery.truncator
//= require jquery.jplayer.min
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
     $('.bio').truncate({max_length: 500})
  });
    
  $("#q").select();

  $("#jpid").jPlayer( {
                      swfPath: "/assets",
                      solution: "html,flash"
                      });
});

function play(url,title)
{
  $('.bio').hide()
  $('#jp_container_1').css('margin-left','20%').css('float','none')
  $('.jp-title').html(title)
  $('#jpid').jPlayer('setMedia',{ mp3: url}).jPlayer('play')
}
