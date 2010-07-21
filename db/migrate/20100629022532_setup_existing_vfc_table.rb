class SetupExistingVfcTable < ActiveRecord::Migration
  def self.up
    unless RAILS_ENV == 'production'
      create_table :vfc do |t|
        t.string :msg
        t.string :subj
        t.string :speaker_name
        t.string :groupmsg
        t.string :date
        t.timestamp :add_date
        t.boolean :download
        t.boolean :publish
        t.string :filename
        t.integer :notes_id
        t.string :language_name
        t.integer :speaker_id
        t.timestamp :change_date
        t.string :duration
        t.integer :filesize
        t.string :place
      end
    else
      execute 'alter table vfc drop column changed'
      execute 'alter table vfc change speaker speaker_name varchar(128)'
      execute 'alter table vfc change language language_name varchar(16)'
      execute 'alter table vfc add column speaker_id int(11)'
      execute 'alter table vfc add column language_id int(11)'
    end
  end

  def self.down
    drop_table :vfc
  end
end
