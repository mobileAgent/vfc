class AddHiddenSpeakers < ActiveRecord::Migration
  def up
    add_column :speakers, :hidden, :boolean, :default => false
    execute "update speakers set hidden = 1 where id not in (select distinct(speaker_id) as speaker_id from audio_messages where publish = 1)"
  end

  def down
    remove_column :speakers, :hidden
  end
end
