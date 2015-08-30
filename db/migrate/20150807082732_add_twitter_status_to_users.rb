class AddTwitterStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :twitter_status, :string
  end
end
