class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [:update, :destroy]
  def create
    @current_cart.add(params[:cart_item][:product_id], params[:cart_item][:variant_id], params[:cart_item][:quantity].to_i)
    respond_to do |format|
      format.html { redirect_to  new_order_path  }
      format.js   { render 'cart/add_cart_item' }
      #format.json { render t 'cart.count', count: @current_cart.cart_items.count  }
    end
  end

  def update
    if @cart_item.update(cart_item_params)
      redirect_to new_order_path, notice: 'Product was successfully updated.'
    else
      redirect_to new_order_path, error: 'Some error.'
    end
  end

  def destroy
    @cart_item.destroy
    respond_to do |format|
      format.html { redirect_to new_order_path }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_item_params
      params.require(:cart_item).permit(:product_id, :quantity, :variant_id)
    end

    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

end
