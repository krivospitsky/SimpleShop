class Admin::PagesController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:name, :enabled]
	# attr_accessor :index_attributes

	
	# def form
	# 	tab :common do |t|
	# 		input :name, t
	# 		ckeditor :text, t
	# 		input :position, t
	# 		input :enabled, t
	# 	end			
	# 	seo
	# end

	private	
	
	def permitted_params
		params.require(:page).permit(:name, :text, :position, :sort_order, :enabled, :image, :remove_image, :sort_order_position, seo_attributes: [:title, :description, :keywords])
	end
end