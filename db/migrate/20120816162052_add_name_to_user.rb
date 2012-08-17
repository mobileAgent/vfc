class AddNameToUser < ActiveRecord::Migration
  def up
    add_column :users, :name, :string, :limit => 128
  end

  def down
    remove_column :users, :name
  end
  
end
