class OrdersController < ApplicationController
  def show
    @order = Order.find_by  secure_key: params[:id]
  end

  def new
    @order=Order.new(cart: @current_cart, state: :Новый)
  end


  def create
    @order = Order.new(order_params)

    if @order.save
      UserMailer.order_confirmation(@order).deliver if ! @order.email.empty?
      UserMailer.new_order(@order).deliver 
      session[:cart_id]=nil
      flash[:info]='Заказ успешно создан'
      respond_with @order, location: "/orders/#{@order.secure_key}"
    else      
      render :action => 'new'
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:cart_id, :state, :name, :city, :phone, :email, :zip, :address, :comment)
    end
end
