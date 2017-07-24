# coding: utf-8
namespace :export do
	task :yml => :environment do 
		 include Rails.application.routes.url_helpers # brings ActionDispatch::Routing::UrlFor
		# include ActionView::Helpers::TagHelper
		 # include ActionView::Helpers
		 # include ApplicationHelper
		 # include ActionView::Helpers::UrlHelpers
		# av = ActionView::Base.new(Rails.root.join('app', 'views'))
		# # av.assign({
		# # 	products: Product.enabled,
		# # 	categories: Category.enabled
		# #   # :regions => @regions,
		# #   # :courts_by_region => @courts_by_region,
		# #   # :cities_by_region => @cities_by_region,
		# #   # :districts_by_region => @districts_by_region
		# # })

		f = File.new('public/uploads/export.yml', 'w')
		f.puts(ActionView::Base.new('app/views').render(file: 'yml'))	 
		f.close
	end
end

