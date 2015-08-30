class AddTweetQuantityToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tweet_quantity, :integer
  end
end
