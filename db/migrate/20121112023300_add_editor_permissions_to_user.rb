class AddEditorPermissionsToUser < ActiveRecord::Migration
  def change
    add_column :users, :place_editor, :boolean
    add_column :users, :speaker_editor, :boolean
    add_column :users, :audio_message_editor, :boolean
    add_column :users, :video_editor, :boolean
    add_column :users, :tags_editor, :boolean
  end
end
