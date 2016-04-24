class OrdersController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:after_pay, :after_pay_error, :ya_kassa_check, :ya_kassa_payment]

  def show
    @order = Order.find_by  secure_key: params[:id]
  end

  def after_pay
    @order = Order.find_by  secure_key: params[:orderNumber]
    # @order.state="Ожидание поступления оплаты"
    # @order.save
    redirect_to "/orders/#{@order.secure_key}", flash: {info: 'Заказ успешно оплачен'}
  end

  def after_pay_error
    @order = Order.find_by  secure_key: params[:orderNumber]
    @order.state="Ошибка оплаты"
    @order.save
    redirect_to "/orders/#{@order.secure_key}", flash: {error: 'Ошибка оплаты заказа'}
  end

  def ya_kassa_check
    @order = Order.find_by  secure_key: params[:orderNumber]
    # if @order.state == "Ожидание поступления оплаты"
      @shopId=params[:shopId]
      @invoiceId=params[:invoiceId]

      # render 'check_ok.xml'
    # end
  end

  def ya_kassa_payment
      @order = Order.find_by  secure_key: params[:orderNumber]
      @order.state="Оплачено"
      @order.save

      @shopId=params[:shopId]
      @invoiceId=params[:invoiceId]

      # render 'check_ok.xml'
  end


  def new
    @order=Order.new
  end


  def create
    @order = Order.new(order_params)
    @order.state='Новый'
    @order.delivery_method_id=params['order']['delivery_method']
    @order.payment_method_id=params['order']['payment_method']
    @current_cart.cart_items.all.each do |cart_item|
      order_item=@order.order_items.new
      order_item.product_name=cart_item.variant.name || cart_item.product.name 
      order_item.product_sku=cart_item.variant.sku
      order_item.product=cart_item.product
      order_item.price=cart_item.variant.price
      order_item.discount_price=cart_item.variant.discount_price
      order_item.quantity=cart_item.quantity
    end

    @order.card_number=params['order']['card_number']
    if @order.card_number
      user=User.find_by card_number: @order.card_number
      if user
        @order.discount=user.discount
      end
    end
    @order.discount |= 0

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
      params.require(:order).permit(:name, :city, :phone, :email, :zip, :address, :comment)
    end
end
