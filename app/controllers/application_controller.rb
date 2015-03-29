
class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_current_cart
  
  before_filter :add_theme_path

  include CurrentCart

  layout 'application'

  private

  def get_current_cart
    @current_cart = ::Cart.find_or_create_by(:id=>session[:cart_id])
    session[:cart_id]=@current_cart.id
  end

  def add_theme_path
    if theme=Settings::theme
      prepend_view_path "app/themes/#{theme}/views/"
    end
  end

end
