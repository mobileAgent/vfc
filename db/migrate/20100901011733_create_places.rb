class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string :name
      t.timestamps
    end

    add_column :vfc, :place_id, :integer, :default => false

    execute 'insert into places(name,created_at,updated_at) select distinct(place) as name, now() as created_at, now() as updated_at from vfc where place is not null'
    execute 'update vfc v set v.place_id = (select p.id from places p where p.name = v.place)'

    remove_column :vfc, :place 
  end

  def self.down
    drop_table :places
  end
end
