class MainController < ApplicationController
  def show
  	@banners=Slide.current
  	@categories=Category.root.enabled
    @title=get_seo_title(nil)
    @last=Product.enabled.last(8)
  end
end
