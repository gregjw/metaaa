class AddMetascoreToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data_metascore, :string
  end
end
