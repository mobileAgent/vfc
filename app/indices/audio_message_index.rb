# thinking-sphinx 3.x index definition for AudioMessage.
# Migrated from the define_index block that lived in app/models/audio_message.rb
# under thinking-sphinx 2.x.
#
# Changes from the 2.x form:
#   - wrapped in ThinkingSphinx::Index.define
#   - delta moved from `set_property :delta => true` into the define options
#   - `has :col, :col` (symbols) -> `has col, col` (field references)
# Delta indexing fires a Sphinx callback on every save. Only enable it in
# production (where real Sphinx runs). In dev/test there's no Sphinx daemon
# — and on arm64 no Sphinx at all — so deltas would error on every record
# save (e.g. FactoryGirl.create in tests).
ThinkingSphinx::Index.define :audio_message, :with => :active_record, :delta => Rails.env.production? do
  where "publish = 1"

  indexes [title, subj], :as => :full_title, :sortable => true
  indexes [speaker.last_name, speaker.first_name, speaker.middle_name, speaker.suffix],
    :as => :speaker_name, :sortable => true
  indexes place.name,        :as => :place,      :sortable => true
  indexes note.title,        :as => :note_title, :sortable => true
  indexes language.name,     :as => :language,   :sortable => true
  indexes event_date,        :sortable => true
  indexes taggings.tag.name, :as => :tags,       :sortable => true

  has filesize, duration, place_id, language_id, speaker_id, note_id
end
