class Admin::CategoriesController < Admin::BaseController

  # def autocomplete
  #   @category = Category.enabled.where("name like ?", "%#{params[:name]}%").limit(10)
  #   respond_to do |format|
  #     format.json { render json: @category.map { |category| category.as_json(:only => :id, :methods => :name) } }
  #   end
  # end

  actions_except [:clone]
  
  def form
    tab :common do |t|
      input :name, t
      ckeditor :description, t
      input :enabled, t
      input :external_id, t
      association :linked_categories, t
      association :linked_products, t
      image :image, t
    end     
    seo
  end

  def index
    @categories=Category.root
    respond_with @categories
  end

  private

  def permitted_params
    params.require(:category).permit(:name, :description, :enabled, :parent_id, :image, :remove_image, :sort_order_position, :linked_category_ids=>[], :linked_product_ids=>[], seo_attributes: [:title, :description, :keywords])
  end
end
