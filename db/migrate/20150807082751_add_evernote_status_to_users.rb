class AddEvernoteStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :evernote_status, :string
  end
end
