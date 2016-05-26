
class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_current_cart
  before_filter :add_theme_path

  before_filter :check_301_redirect
  # before_filter :set_controller_and_action_names


  layout :layout_by_resource
  # layout 'application'

  private

  include CurrentCart
  
  # def set_controller_and_action_names
  #   @current_controller = controller_name
  #   @current_action     = action_name
  # end

  def get_current_cart
    @current_cart = ::Cart.find_or_create_by(:id=>session[:cart_id])
    session[:cart_id]=@current_cart.id
  end

  def add_theme_path
    if theme=Settings::theme
      prepend_view_path "app/themes/#{theme}/views/"
    end
  end

  def get_seo_title(obj)
    return obj.seo.title if obj && obj.seo && obj.seo.title && obj.seo.title!=''
    return "#{obj.name} - купить в Калуге, #{Settings.site_title}" if controller_name =='products' && (action_name=='index' || action_name=='show') 
    return "Результаты поиска - #{Settings.site_title}" if controller_name =='products' && action_name=='search'
    return "#{obj.name} - #{Settings.site_title_2} #{Settings.site_title}" if controller_name =='pages'
    return "#{Settings.site_title_2} #{Settings.site_title}" if controller_name =='main'
  end

  def get_meta_keywords(obj)
    return obj.seo.keywords if obj && obj.seo && obj.seo.keywords && obj.seo.keywords!=''
    if obj.attribute_names.include?("name")
      ret=obj.name 
    elsif obj.attribute_names.include?("title")
      ret=obj.title       
    end
    return ret if ret
  end

  def get_meta_description(obj)
    return obj.seo.description if obj && obj.seo && obj.seo.description && obj.seo.description!=''
    if obj.attribute_names.include?("description")
      ret=obj.description 
    elsif obj.attribute_names.include?("text")
      ret=obj.text    
    end
    return ret[0, 175] if ret
  end

  def set_seo_variables(obj)
    @title=get_seo_title(obj)
    @meta_keywords=get_meta_keywords(obj)
    @meta_description=get_meta_description(obj)
  end

  def check_301_redirect
    redirect_to "http://xn----7sbababs6ccgf5c8b6f.xn--p1ai#{request.fullpath}", :status => 301  if request.host == 'fish-kaluga.ru' || request.host == 'www.fish-kaluga.ru'
  end

    def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

end
