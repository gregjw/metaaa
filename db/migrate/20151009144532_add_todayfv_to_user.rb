class AddTodayfvToUser < ActiveRecord::Migration
  def change
    add_column :users, :todayfv, :integer
  end
end
