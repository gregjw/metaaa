class AddInstagramKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instagram_key, :string
  end
end
