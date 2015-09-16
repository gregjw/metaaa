class AddAverageFavouritesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data_averagef, :string
  end
end
