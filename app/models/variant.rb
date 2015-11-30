include ProductsHelper

class Variant < ActiveRecord::Base
  belongs_to :product
  scope :enabled, -> { where(enabled: 't') }

  has_many :attrs, dependent: :destroy, class_name: :VariantAttr
  accepts_nested_attributes_for :attrs, allow_destroy:true

  mount_uploader :image, ImageUploader

  after_save :recalc_min_max_prices

  validates :price, presence: true

  def recalc_min_max_prices
    if product
      prices=product.variants.map {|v| v.price}   
      product.min_price=prices.min
      product.max_price=prices.max
      product.save
    end
  end

  def discount_price
    max_discount1 = Promotion.current.joins(:products).where('products.id = ?', product.id).maximum(:discount) || 0
    max_discount2 = Promotion.current.joins(:categories).where('categories.id in (?)', product.categories.flat_map{|c| c.parent_ids}).maximum(:discount) || 0
    max_discount = [max_discount1, max_discount2].max

    if max_discount>0
      return price * (100 - max_discount) / 100
    else
      return nil
    end
  end


  def price_str(quantity=1)
    if !price
      "по запросу"
    elsif discount_price
      "<del>#{to_price(price*quantity)}</del>&nbsp;#{to_price(discount_price*quantity)}"
    else
      "#{to_price(price*quantity)}"
    end
  end
end
