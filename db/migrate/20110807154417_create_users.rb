class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :user_id
      t.string :access_token
      t.string :access_token_secret
      t.string :screen_name
      t.string :birthday

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
