class Admin::PromotionsController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :enabled, :start_at, :end_at]
	private

	def permitted_params
		params.require(:promotion).permit(:name, :description, :enabled, :has_banner, :banner, :send_mail, :start_at, :end_at, :discount, category_ids:[], product_ids:[], seo_attributes: [:title, :description, :keywords])
	end
end
