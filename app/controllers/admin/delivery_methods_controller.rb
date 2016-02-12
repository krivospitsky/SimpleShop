class Admin::DeliveryMethodsController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :enabled]
	private

	def permitted_params
		params.require(:delivery_method).permit(:name, :enabled, :description, :hide, :min_price, :max_price, :price, :payment_method_ids=>[])
	end
end
