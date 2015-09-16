class AddTaskStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :task_status, :string
  end
end
