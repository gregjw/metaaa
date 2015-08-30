class AddPocketStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pocket_status, :string
  end
end
