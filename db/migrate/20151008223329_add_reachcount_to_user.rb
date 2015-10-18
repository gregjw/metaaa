class AddReachcountToUser < ActiveRecord::Migration
  def change
    add_column :users, :reachcount, :integer
  end
end
