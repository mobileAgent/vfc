class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name

      t.timestamps
    end
    
    execute 'insert into languages(name,created_at,updated_at) select distinct(language_name) as name, now() as created_at,now() as updated_at from vfc where language_name REGEXP "[A-Z].*"'
    execute 'update vfc v set v.language_id = (select l.id from languages l where l.name = v.language_name)'

  end

  def self.down
    drop_table :languages
  end
end
