class CreateSpeakers < ActiveRecord::Migration
  def self.up
    create_table :speakers do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :suffix
      t.text :bio
      t.string :picture_file

      t.timestamps
    end
  end

  def self.down
    drop_table :speakers
  end
end
