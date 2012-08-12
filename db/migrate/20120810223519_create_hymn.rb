class CreateHymn < ActiveRecord::Migration
  def up
    create_table :hymns do |t|
      t.string :title, :limit => 128, :null => false
      t.string :filename, :limit => 256, :null => false
      t.timestamps
    end
  end

  def down
    drop_table :hymns
  end
end
