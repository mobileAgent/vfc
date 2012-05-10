class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :email, :limit => 128, :default => "", :null => false
      t.string :hashed_password, :default => "", :null => false
      t.string :salt, :null => false
      t.boolean :admin, :default => false, :null => false
      t.boolean :activated, :default => false, :null => false
      t.integer :lock_version, :default => 0, :null => false
      t.timestamp :last_visit, :null => false
      t.timestamps 
    end
  end

  def down
    drop_table :users
  end
end
