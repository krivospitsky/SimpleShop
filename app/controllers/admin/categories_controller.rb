class Admin::CategoriesController < Admin::BaseController

  # def autocomplete
  #   @category = Category.enabled.where("name like ?", "%#{params[:name]}%").limit(10)
  #   respond_to do |format|
  #     format.json { render json: @category.map { |category| category.as_json(:only => :id, :methods => :name) } }
  #   end
  # end


  def index
    @categories=Category.root
    @h1 = (t("title.#{controller_name}.#{action_name}")) + '&nbsp;' + (view_context.link_to t('.new', :default => t("helpers.links.new")), new_admin_category_path, :class => 'btn btn-primary')

    respond_with @categories
  end

  private

  def permitted_params
    params.require(:category).permit(:name, :description, :enabled, :parent_id, :image, :remove_image, :sort_order_position, :linked_category_ids=>[], :linked_product_ids=>[], seo_attributes: [:title, :description, :keywords])
  end
end
