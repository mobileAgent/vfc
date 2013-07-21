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

function audio_player_start()
{
    $("#jpid").jPlayer({
        swfPath: "/assets",
        solution: "html,flash"
    });
}

function video_player_start()
{
    $("#jquery_jplayer_1").jPlayer({
        swfPath: "/assets",
        supplied: "m4v",
        solution: "html,flash",
        cssSelectorAncestor: "#jpid"
    });
    $("#jpid")
    .css('width','60%')
    .css('margin-left','20%')
    .css('float','none')
    $("#jquery_jplayer_1").css('margin-left','15%');
}

function document_setup()
{
  $("#q").autocomplete({
    source: '/welcome/search',
    minLength: 2,
    autoFocus: true,
    select: function(event,ui) {
       $("#q").val(ui.item.value);
       $("#sform").submit();
       }        
  });
  $(function() {
     $('.bio').truncate({max_length: 500})
  });
  $("#q").select();
  if (document.location.href.indexOf("/videos/") > -1)
    video_player_start();
  else
    audio_player_start();
};

$(document).ready(document_setup)
$(document).on("page:load",document_setup)
