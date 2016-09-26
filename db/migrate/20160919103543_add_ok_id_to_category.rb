class AddOkIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :ok_id, :integer
  end
end
