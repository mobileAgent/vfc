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

});

function play(url,title)
{
  $('.bio').hide()
  $('#jp_container_1').css('margin-left','20%').css('float','none')
  $('.jp-title').html(title)
  $('#jpid').jPlayer('setMedia',{ mp3: url}).jPlayer('play')
}

function video_play(url,title)
{
  $('.jp-title').html(title)
  $('#jquery_jplayer_1').jPlayer('setMedia',{ m4v: url}).jPlayer('play')
}
