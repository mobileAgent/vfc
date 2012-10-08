class ChangeNoteAttachmentToAudioMessage < ActiveRecord::Migration
  def up
    execute 'alter table audio_messages change column notes_id note_id int'
  end

  def down
    execute 'alter table audio_messages change column note_id notes_id int'
  end
end
