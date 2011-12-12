class CreateBlockedHost < ActiveRecord::Migration
  def up
    create_table :blocked_hosts do |t|
      t.string :ip_address
      t.timestamps
    end
  end

  def down
    drop_table :blocked_hosts
  end
end
