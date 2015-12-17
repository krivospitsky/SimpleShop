class Admin::DiscountsController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :discount, :enabled, :start_at, :end_at]
	private

	def permitted_params
		params.require(:discount).permit(:name, :enabled, :start_at, :end_at, :discount, category_ids:[], product_ids:[])
	end
end
