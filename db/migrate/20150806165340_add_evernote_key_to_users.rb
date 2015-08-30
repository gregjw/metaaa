class AddEvernoteKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :evernote_key, :string
  end
end
