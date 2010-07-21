class CreateMotms < ActiveRecord::Migration
  def self.up
    create_table :motms do |t|
      t.integer :audio_message_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :motms
  end
end
