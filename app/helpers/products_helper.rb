include ActionView::Helpers::NumberHelper 
module ProductsHelper
	def to_price (price)
		number_to_currency(price, precision: 0, unit: '')
	end
end
