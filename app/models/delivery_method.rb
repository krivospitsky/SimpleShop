class DeliveryMethod < ActiveRecord::Base

  scope :enabled, -> { where(enabled: 't') }
  has_and_belongs_to_many :payment_methods

  def text
  	if price && price > 0
  		"#{name} (+#{price} руб.)"
  	else
  		name
  	end
  end

  def applicable?(price)
  	(min_price.to_i==0 || min_price<price) && (max_price.to_i==0 || max_price>price)
  end

end
