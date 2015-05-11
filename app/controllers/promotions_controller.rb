class PromotionsController < ApplicationController
	def show
		@promotion=Promotion.find(params[:id])
	    set_seo_variables(@promotion)
	end
end
