class AddDropboxSecretToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_secret, :string
  end
end
