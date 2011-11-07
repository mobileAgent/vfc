AUDIO_URL = "http://voicesforchrist.org/VFC-GOLD/"
AUDIO_PATH = Rails.root.to_s == "production" ?
                "/var/apps/vfc/shared/audio/VFC-GOLD/" :
                "#{Rails.root.to_s}/public/audio/VFC-GOLD/"


WRITINGS_URL = "/writings/get?name="
WRITINGS_PATH = Rails.root.to_s == "production" ?
               "/var/apps/vfc/shared/writings/" :
               "#{Rails.root.to_s}/public/writings/"


PHOTOS_URL = "/photos/"
PHOTOS_PATH = "#{Rails.root.to_s}/public/photos/"

AUDIO_MIME_PLAY = "audio/x-mpegurl"
AUDIO_MIME_DL = "application/binary"
