class Category < ActiveRecord::Base
	has_many :products
	has_many :children, :class_name => "Category",
    	:foreign_key => "parent_id"
	belongs_to :parent, :class_name => "Category"

  has_and_belongs_to_many(:products,
    class_name: 'Product',
    :join_table => "categories_products")

  has_and_belongs_to_many(:linked_products,
    class_name: 'Product',
    :join_table => "categories_linked_products")

  has_and_belongs_to_many(:linked_categories,
    class_name: 'Category',
    :join_table => "categories_linked_categories",
    :association_foreign_key=> 'linked_category_id')

  scope :enabled, -> { where(enabled: 't') }


  mount_uploader :image, ImageUploader

  include  Seoable

  attr_accessor :delete_image
  before_validation { self.image.clear if self.delete_image == '1' }

  def path
    return parent.next_path if parent
    nil
  end

  def next_path
    return parent.next_path+"/"+id.to_s if parent
    id.to_s
  end

  def all_sub_cats
    sub_cats=[]
    children.each do |sub|
      sub_cats += sub.all_sub_cats
    end
    sub_cats << self
  end

  def products_in_all_sub_cats
    Product.enabled.joins(:categories).where('category_id in (?)', all_sub_cats().map{|a| a.id})
  end

# def products_in_all_sub_cats
#     all_products = products.enabled.to_a
#     children.each do |sub|
#       all_products += sub.products_in_all_sub_cats
#       end

#     all_products
#   end

end
