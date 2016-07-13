class Admin::PaymentMethodsController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :enabled]
	private

	def permitted_params
		params.require(:payment_method).permit(:name, :description, :hide, :use_online, :enabled, :online_type)
	end
end
