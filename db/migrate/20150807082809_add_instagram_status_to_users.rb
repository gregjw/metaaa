class AddInstagramStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :instagram_status, :string
  end
end
