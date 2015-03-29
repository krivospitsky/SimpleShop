module ApplicationHelper
  def product_path(product, category=nil)
  	if Settings.disable_categories
		original_product_path('', product)
  	else
	  	category ||= product.categories.first 
	  	if category
	  		original_product_path(category.path, category.id, product)
	  	else
	  		canonical_product_path(product)	  		
	  	end
	end
  end

  def catalog_path
  	'/catalog'
	#root_path
  end


 #  def page_path(page)
 #  	if page == Page.first
	# 	root_path
 #  	else
	# 	original_page_path(page)
	# end
 #  end
end
