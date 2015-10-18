class AddTodayrtToUser < ActiveRecord::Migration
  def change
    add_column :users, :todayrt, :integer
  end
end
