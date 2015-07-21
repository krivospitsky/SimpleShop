class OrderItem < ActiveRecord::Base
	belongs_to :order
	belongs_to :product

	def price_str(quantity=1)
		if !price
			"по запросу"
		elsif discount_price
			"<del>#{price*quantity}</del>&nbsp;#{discount_price*quantity} руб."
		else
			"#{price*quantity}&nbsp;руб."
		end
	end
end
