class AddOkIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :ok_id, :integer
  end
end
