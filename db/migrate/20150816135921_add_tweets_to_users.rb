class AddTweetsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tweet, :string
  end
end
