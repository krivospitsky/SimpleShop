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
		if Settings.theme == 'mama40' || Rails.env.development?
			cat_ids=[]
			[31, 12, 4, 19, 41, 51].each do |c|
				cat_ids << c
				cat_ids << Category.find(c).all_sub_cats.map{|c| c.id}
			end
			@categories=Category.enabled.where(id: cat_ids)
		else
			@categories=Category.enabled
		end
		@products=Product.enabled.in_categories(@categories)
		f.puts(ActionView::Base.new('app/views').render(file: 'yml'))	 
		f.close
	end
end

