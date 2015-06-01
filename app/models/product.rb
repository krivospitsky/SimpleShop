#coding:utf-8
class Product < ActiveRecord::Base
  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images, allow_destroy:true

  has_many :attrs, :dependent => :destroy
  accepts_nested_attributes_for :attrs, allow_destroy:true

  has_many :variants, :dependent => :destroy
  accepts_nested_attributes_for :variants, allow_destroy:true

  has_and_belongs_to_many(:categories,
    :join_table => "categories_products")

  has_and_belongs_to_many(:linked_categories,
    class_name: 'Category',
    :join_table => "products_linked_categories")

  has_and_belongs_to_many(:linked_products,
    class_name: 'Product',
    :join_table => "products_linked_products",
    :association_foreign_key=> 'linked_product_id' )

  include RankedModel
    ranks :sort_order

  include  Seoable

  # serialize :attr, Hash

  amoeba do
    enable
      prepend :name => "КОПИЯ "
      set enabled: false
      exclude_association :images
      customize(lambda { |original_item,new_item|
        original_item.images.each{|p| new_item.images.new :image => p.image.file}
      })
  end

  # default_scope -> {order(sort_order: :asc)}
  scope :enabled, -> { where(enabled: 't') }
  #scope :enabled, -> { joins(:variants).where("variants.enabled" => 't') }

  scope :in_categories, ->(cats) {enabled.joins(:categories).where('category_id in (?)', cats.map{|a| a.id})}

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

    max_discount2 = Promotion.current.joins(:categories).where('categories.id in (?)', categories.flat_map{|c| c.parent_ids}).maximum(:discount) || 0
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
    if variants.count==0
      "по запросу"
    else
      discount=get_discount
      c=1
      if discount && discount>0
        c=(100-discount)/100.0
      end
      if min_price == max_price
        "#{(min_price*c).to_i} <small>руб.</small>"
      else
        "<small>от</small> #{(min_price*c).to_i} <small>до</small> #{(max_price*c).to_i} <small>руб.</small>"
      end
    end
  end
  
  def old_price_str
    discount=get_discount
    if discount && discount>0
      if min_price == max_price
        "#{min_price} <small>руб.</small>"
      else
        "<small>от</small> #{min_price} <small>до</small> #{max_price} <small>руб.</small>"
      end
    else
      ""
    end
  end

end
