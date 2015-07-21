class Admin::OrdersController  < Admin::BaseController
	actions [:index, :show]
	index_attributes [:name, :email, :phone, :created_at, :state]
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def permitted_params
      params.require(:order).permit(:name, :city, :phone, :email, :zip, :address, :comment, order_items_attributes:[:id, :product_name, :product_sku, :price, :discount_price, :quantity, :_destroy])
    end

end
