class AddTodayactivityToUser < ActiveRecord::Migration
  def change
    add_column :users, :todayactivity, :integer
  end
end
