class Admin::PromotionsController < Admin::BaseController

	def index
	    @h1 = (t("title.#{controller_name}.#{action_name}")) + '&nbsp;' + (view_context.link_to t('.new', :default => t("helpers.links.new")), new_admin_promotion_path, :class => 'btn btn-primary')
	    super
	end

  private

  def permitted_params
    params.require(:promotion).permit(:name, :description, :enabled, :has_banner, :banner, :send_mail, :start_at, :end_at, :discount, category_ids:[], product_ids:[], seo_attributes: [:title, :description, :keywords])
  end
end
