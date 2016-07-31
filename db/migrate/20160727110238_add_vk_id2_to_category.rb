class AddVkId2ToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :vk_id2, :integer
  end
end
