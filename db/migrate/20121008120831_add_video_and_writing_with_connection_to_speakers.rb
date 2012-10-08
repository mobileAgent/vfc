class AddVideoAndWritingWithConnectionToSpeakers < ActiveRecord::Migration
  def up
    create_table :videos do |t|
      t.string :title, :limit => 128, :null => false
      t.string :filename, :limit => 256, :null => false
      t.integer :speaker_id
      t.integer :duration #minutes
      t.boolean :delta, :default => false
      t.timestamp :event_date
      t.timestamps
    end

    create_table :writings do |t|
      t.string :title, :limit => 128, :null => false
      t.string :filename, :limit => 256, :null => false
      t.integer :speaker_id
      t.integer :filesize
      t.boolean :delta, :default => false
      t.timestamp :event_date
      t.timestamps
    end

    create_table :notes do |t|
      t.string :title, :limit => 128, :null => false
      t.string :filename, :limit => 256, :null => false
      t.integer :speaker_id
      t.integer :filesize
      t.boolean :delta, :default => false
      t.timestamps
    end
  end

  def down
    drop_table :videos
    drop_table :writings
    drop_table :notes
  end
end
