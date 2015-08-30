class AddDropboxStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dropbox_status, :string
  end
end
