class AddDaysToUsers < ActiveRecord::Migration
  def change
    add_column :users, :days, :integer
  end
end
