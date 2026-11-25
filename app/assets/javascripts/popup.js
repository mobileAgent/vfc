function dl(el) {
    var url = $(el).attr('href');
    if (vfc_link_expired(url)) {
        return vfc_audio_refused();
    }
    var hiddenIFrameID = 'hiddenDownloader',
        iframe = document.getElementById(hiddenIFrameID);
    if (iframe === null) {
        iframe = document.createElement('iframe');
        iframe.id = hiddenIFrameID;
        iframe.style.display = 'none';
        document.body.appendChild(iframe);
        // A download that starts leaves the frame empty; a refusal loads
        // the server's short message into it, so show that on the page.
        iframe.onload = function() {
            try {
                var text = iframe.contentDocument.body.textContent.trim();
                if (text) { vfc_audio_refused(text); }
            } catch (e) {}
        };
    }
    iframe.src = url;
    return false;
}
