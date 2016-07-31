class AddVkId2ToProduct < ActiveRecord::Migration
  def change
    add_column :products, :vk_id2, :integer
  end
end
