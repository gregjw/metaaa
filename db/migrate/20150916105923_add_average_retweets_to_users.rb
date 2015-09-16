class AddAverageRetweetsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data_averager, :string
  end
end
