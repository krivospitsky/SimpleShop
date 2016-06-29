class AddVkIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :vk_id, :integer
  end
end
