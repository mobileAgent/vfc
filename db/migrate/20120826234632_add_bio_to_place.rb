class AddBioToPlace < ActiveRecord::Migration
  def up
    add_column :places, :bio, :text
    add_column :places, :picture_file, :string, :limit => 512
  end

  def down
    remove_column :places, :bio
    remove_column :places, :picture_file
  end
end
