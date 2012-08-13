AUDIO_URL = "http://voicesforchrist.org/VFC-GOLD/"
AUDIO_PATH = Rails.env == "production" ?
                "/var/apps/vfc/shared/audio/VFC-GOLD/" :
                "#{Rails.root.to_s}/public/audio/VFC-GOLD/"


WRITINGS_URL = "/writings/get?name="
WRITINGS_PATH = Rails.env == "production" ?
               "/var/apps/vfc/shared/writings/" :
               "#{Rails.root.to_s}/public/writings/"


PHOTOS_URL = "/photos/"
PHOTOS_PATH = "#{Rails.root.to_s}/public/photos/"

AUDIO_MIME_PLAY = "audio/mpeg"
AUDIO_MIME_DL = "application/binary"

TLD_TO_LOCALE_MAP = {
  'voicesforchrist.org' => 'en',
  'vocesparacristo.org' => 'es',
  'voixpourchrist.org' => 'fr',
  'www.voicesforchrist.org' => 'en',
  'www.vocesparacristo.org' => 'es',
  'www.voixpourchrist.org' => 'fr',
  'vfc-es.lvh.me' => 'es',
  'vfc-fr.lvh.me' => 'fr',
  'vfc-en.lvh.me' => 'en',
  'vfc.lvh.me' => 'en',
}

require 'file_file'
