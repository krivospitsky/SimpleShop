class Admin::SlidesController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :enabled, :start_at, :end_at]
	private

	def permitted_params
		params.require(:slide).permit(:name, :enabled, :start_at, :end_at, :image, :url)
	end
end
