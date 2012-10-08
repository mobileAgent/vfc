class AddDeltaIndexSupport < ActiveRecord::Migration
  def up
    add_column :audio_messages, :delta, :boolean, :default => false
    add_column :speakers, :delta, :boolean, :default => false
    add_column :places, :delta, :boolean, :default => false
  end

  def down
    remove_column :audio_messages, :delta
    remove_column :speakers, :delta
    remove_column :places, :delta
  end
end
