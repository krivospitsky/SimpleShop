class MainController < ApplicationController
  def show
  	@banners=Slide.current
  	@categories=Category.root.enabled
    @title=get_seo_title(nil)
  end
end
