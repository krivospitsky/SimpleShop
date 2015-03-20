#coding:utf-8
class Product < ActiveRecord::Base
  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, allow_destroy:true

  has_many :variants, :dependent => :destroy
  accepts_nested_attributes_for :variants, allow_destroy:true

  include RankedModel
    ranks :sort_order

  include  Seoable

  serialize :attr, Hash

  default_scope -> {order(sort_order: :asc)}
  scope :enabled, -> { where(enabled: 't') }
  #scope :enabled, -> { joins(:variants).where("variants.enabled" => 't') }

  has_and_belongs_to_many(:categories,
    :join_table => "categories_products")

  has_and_belongs_to_many(:linked_categories,
    class_name: 'Category',
    :join_table => "products_linked_categories")

  has_and_belongs_to_many(:linked_products,
    class_name: 'Product',
    :join_table => "products_linked_products",
    :association_foreign_key=> 'linked_product_id' )

  def self.search(search)
    where('lower(name) LIKE lower(:search)', search: "%#{search}%")
  end

  # def price
  #   prices=variants.map {|v| v.price}
  #   if prices.min == prices.max
  #     return prices[0]
  #   else
  #     return "от #{prices.min} до #{prices.max}"
  #   end
  # end

  def availability
	  # return 'В наличии' if count>0
	  # return 'Под заказ' if count==0
    return 'В наличии'
	end

  def linked
    result=[]

    result += linked_products.enabled

    linked_categories.each do |cat|
      result += cat.products.enabled
    end

    categories.each do |cat|
      result += cat.linked_products.enabled

      cat.linked_categories.each do |cat|
        result += cat.products.enabled
      end
    end
    result-=[self]
    result.uniq[0..7]
  end

  def get_discount
    max_discount1 = Promotion.current.joins(:products).where('products.id = ?', id).maximum(:discount) || 0
    max_discount2 = Promotion.current.joins(:categories).where('categories.id in (?)', categories.pluck(:id)).maximum(:discount) || 0
    max_discount = [max_discount1, max_discount2].max

    max_discount

    # #
    # if max_discount>0
    #   return price * (100 - max_discount) / 100
    #   # 
    #   #   return prices[0] * (100 - max_discount) / 100
    #   # else
    #   #   return "от #{prices.min * (100 - max_discount) / 100} до #{prices.max * (100 - max_discount) / 100}"
    #   # end
    # end

    # false
  end

  def price_str
    prices=variants.map {|v| v.price}   
    discount=get_discount
    if prices.count==0
      "по запросу"
    elsif discount && discount>0
      if prices.min == prices.max
        "<del>#{prices[0]}</del> #{prices[0] * (100-discount)/100} руб."
      else
        "<del>от #{prices.min} до #{prices.max} руб.</del> от #{prices.min * (100-discount)/100} до #{prices.max * (100-discount)/100} руб."
      end
    else
      if prices.min == prices.max
        "#{prices[0]} руб."
      else
        "от #{prices.min} до #{prices.max} руб."
      end
    end
  end

end
