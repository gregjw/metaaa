class AddFacebookKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_key, :string
  end
end
