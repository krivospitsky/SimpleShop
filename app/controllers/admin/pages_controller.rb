class Admin::PagesController < Admin::BaseController
	
	def index
	    @h1 = (t("title.#{controller_name}.#{action_name}")) + '&nbsp;' + (view_context.link_to t('.new', :default => t("helpers.links.new")), new_admin_page_path, :class => 'btn btn-primary')
	    super
	end

	private	
	
	def permitted_params
		params.require(:page).permit(:name, :text, :position, :sort_order, :enabled, :image, :sort_order_position, seo_attributes: [:title, :description, :keywords])
	end
end