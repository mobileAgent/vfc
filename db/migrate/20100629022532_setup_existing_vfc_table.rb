class SetupExistingVfcTable < ActiveRecord::Migration
  def self.up
    create_table :audio_messages do |t|
      
      t.string :title
      t.string :subj
      t.string :groupmsg
      
      t.boolean :publish, :default => true, :null => false
      
      t.integer :notes_id
      t.integer :language_id
      t.integer :speaker_id
      t.integer :place_id
      
      t.string :filename
      t.integer :duration # seconds
      t.integer :filesize

      t.integer :download_count
      t.integer :order_count
      
      t.timestamp :event_date
      t.timestamps
    end
    
    create_table :motms do |t|
      t.integer :audio_message_id
      t.timestamps
    end

    create_table :orders do |t|
      t.integer :user_id
      t.boolean :fulfilled, :default => false, :null => false
      t.timestamps
    end

    create_table :users do |t|
      t.string :last_name
      t.string :first_name
      t.string :title
      t.string :email_address
      t.string :address1
      t.string :address2
      t.string :phone1
      t.string :phone2
      t.string :city
      t.string :state
      t.string :region
      t.string :cc
      t.string :zip
      t.string   :encrypted_password, :limit => 128
      t.string   :salt,               :limit => 128
      t.string   :confirmation_token, :limit => 128
      t.string   :remember_token,     :limit => 128
      t.boolean  :email_confirmed, :default => false, :null => false
      t.timestamps
    end
    
    create_table :speakers do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :suffix
      t.text :bio
      t.string :picture_file
      t.timestamps
    end
    
    create_table :languages do |t|
      t.string :name
      t.string :cc
      t.timestamps
    end
    
    create_table :places do |t|
      t.string :name
      t.string :cc
      t.timestamps
    end
    
    create_table :tags do |t|
      t.string :name
    end
    
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.timestamp :created_at
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :audio_messages, [:title, :subj]
    add_index :audio_messages, :language_id,
    add_index :audio_messages, :place_id,
    add_index :audio_messages, :speaker_id,
    add_index :audio_messages, :event_date
    add_index :speakers, [:last_name, :first_name, :middle_name]
    add_index :places, :name
    
    add_index :users, [:id, :confirmation_token]
    add_index :users, :email
    add_index :users, :remember_token
    
  end

  def self.down
    drop_table :audio_messages
    drop_table :motms
    drop_table :speakers
    drop_table :languages
    drop_table :tags
    drop_table :taggings
    drop_table :places
    drop_table :users
    drop_table :orders
  end
end
