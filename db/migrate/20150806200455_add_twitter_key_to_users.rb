class AddTwitterKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_key, :string
  end
end
