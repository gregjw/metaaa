class AddFollowerarrayToUser < ActiveRecord::Migration
  def change
    add_column :users, :follower_array, :string
  end
end
