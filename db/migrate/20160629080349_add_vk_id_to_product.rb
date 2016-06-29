class AddVkIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :vk_id, :integer
  end
end
