class MainController < ApplicationController
  def show
  	@banners=Promotion.current_banners
  	@categories=Category.root.enabled
    @title=get_seo_title(nil)
  end
end
