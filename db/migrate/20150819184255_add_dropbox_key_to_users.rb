class AddDropboxKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_key, :string
  end
end
