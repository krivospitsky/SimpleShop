# coding: utf-8
namespace :import do
	task :ellevill => :environment do

		$base_url='http://www.ellevill.org'
		$sku_prefix=''

		EllevillProcessCategory("http://www.ellevill.org/category/cotton/", -1, :only_subcat)
		EllevillProcessCategory("http://www.ellevill.org/category/ringsling/", -1, :only_subcat)
		EllevillProcessCategory("http://www.ellevill.org/category/maysling/", -1, :only_products)
		EllevillProcessCategory("http://www.ellevill.org/category/ergorukzak/", -1, :only_products)
	end

	def EllevillProcessCategory(url, id, type)
		cat = Nokogiri::HTML(open(url))

		if id==-1
			external_id=$sku_prefix + url[/\/([^\/]+)\/$/,1]
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=cat.xpath('//h1').first.content.strip
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end

		if type==:only_subcat
			cat.xpath('//div[@class="subcategories"]//a').each do |subcat|
				sub_url=$base_url+subcat.attr('href')
				puts sub_url
				external_id=$sku_prefix + sub_url[/\/([^\/]+)\/$/,1]

				category=Category.find_or_initialize_by(external_id: external_id)
				if category.new_record?
					category.parent_id=id
					category.external_id=external_id
					category.name=subcat.content.strip.gsub(/\(\d+\)/,'').strip
					puts category.name
					category.enabled=true
					category.save!
				end

				EllevillProcessCategory(sub_url, category.id, :only_products)
			end
		end

			# if next_url=cat.xpath('//a[@class="modern-page-next"]/@href').first
			# 	EllevillProcessCategory($base_url+next_url.content, id, :only_products)
			# end

		if type==:only_products
			cat.xpath('//a[@class="product-title"]/@href').each do |prod_link|
				prod = Nokogiri::HTML(open($base_url+prod_link), nil)

				# next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first || prod.xpath('//table[@class="offers_table"]').first

				puts prod_link
				sku=$sku_prefix + prod_link.content[/\/([^\/]+)\/$/,1]
				#prod.xpath('//span[@class="code"]').first.content
				product=Product.find_or_initialize_by(sku: sku)
				if product.new_record?
				 	product.name=prod.xpath('//h1').first.content.strip
				 	puts product.name
				 	product.categories.clear
				 	product.categories << Category.find(id)
				 	product.sku=sku				
				 	if descr=prod.xpath('//div[@id="content_description"]').first
						descr.css('img').each do |img|
							url=img.attr('src')
							unless image=DescriptionImage.find_by(original_url: url)
								image=DescriptionImage.new
								image.original_url=url
								# url=url[/^\.\.(.*)$/,1] if url.start_with?('..')
								url = "#{$base_url}#{url}" unless url.start_with?($base_url)
								image.remote_image_url=url
								image.save
							end
							img.attributes['src'].value=image.image.url					
						end
						product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
					end
				end
	
				product.enabled=true
				product.save

				base_price=prod.xpath('//p[@class="actual-price"]//span[@class="price-num"]').first.content.strip.to_i

				variants=prod.xpath('//select/option | //label[@class="option-items"]')
				if variants.empty? 
					variant=product.variants.find_or_initialize_by(sku: sku)
					variant.name=product.name
					variant.enabled=true
					variant.availability='Доставка 3-4 дня'
					variant.price=base_price
					variant.save					
				else
					variants.each do |var|
						var_string=var.content.strip.gsub("\u00A0", "")
						var_string='4.7m (M)' if var_string == '4.7m'
						var_string='5.2m (L)(+300 р.)' if var_string == '5.2m(+300р.)'
						var_string='4.2m (S)(-300 р.)' if var_string == '4.2m(-300р.)'
						if var_string[/\(([MSXL]+)\)/, 1]
							long_size=var_string[/^(.*?\))/, 1]
							short_size=var_string[/\(([MSXL]+)\)/, 1]
							price_delta=var_string[/\(([+-]\d+).*\)/, 1].to_i 
						elsif var_string[/^([МMSXL]+\s+\(.+?\))$/, 1]
							long_size=short_size=var_string
							price_delta=0
						else
							raise "strange size '#{var_string}'"
						end
						puts var_string
	 					
						var_sku="#{sku}_" + short_size
						variant=product.variants.find_or_initialize_by(sku: var_sku)
						variant.name="#{product.name} " + long_size
						variant.enabled=true
						variant.availability='Доставка 3-4 дня'
						variant.price=base_price + price_delta
						as=variant.attrs.find_or_initialize_by(name: 'Размер')
						as.value=long_size
						as.save
						variant.save
					end
				end


				if product.images.count == 0 
					prod_images=prod.xpath('//a[@class="cm-thumbnails-mini  cloud-zoom-gallery cm-previewer"]/@href')
					prod_images=prod.xpath('//a[@class="cloud-zoom cm-image-previewer cm-previewer"]/@href') if prod_images.empty?
					prod_images.each do |pic_url|
						# sleep 3
						begin
							image=product.images.new
							image.remote_image_url=$base_url+pic_url
							image.save
						rescue
							image.delete
						end
					end
				end
				# sleep 3
			end
		end
	end
end