class AddTrialToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trial, :boolean
  end
end
