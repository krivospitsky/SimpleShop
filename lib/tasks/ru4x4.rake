# coding: utf-8
namespace :import do
	task :ru4x4 => :environment do 

		$base_url='http://www.4x4ru.ru'
		$sku_prefix='ru_'

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/akkumulyatory_gelevye/", -1, 'only_subcat')
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/benzobaki_uvelichennoy_yemkosti/", -1, 'only_subcat')
		unless Rails.env.development?
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/bortovye_kompyutery/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_zimy/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya-atv/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_nivy_i_shevi_nivy/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya-snegokhodov/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_uaz_1/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_khraneniya_i_perevozki/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_ekspeditsiy_puteshestviy_i_off_road/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/domkraty_1/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dopolnitelnyy_svet/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/raptor/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/kanistry_ekspeditsionnye/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/kompressory/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/lebedki/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/lodki/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/navesnoe_i_silovoe_oborudovanie/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/rasshiriteli_arok/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/stropy_i_takelazh/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/send_traki/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/tekhnika_dlya_bezdorozhya/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/transmissiya_i_podveska_1/", -1, 'only_subcat')
			Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/shiny_diski_i_aksessuary_k_nim/", -1, 'only_subcat')
		end
	end

	def Ru4x4ProcessCategory(url, id, type)

		cat = Nokogiri::HTML(open(url+'?ncc=1'))

		if id==-1
			external_id=$sku_prefix + url[/\/([^\/]+)\/$/,1]
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=cat.xpath('(//div[@class="bx_breadcrumbs clear"])[1]/ul/li[last()]').first.content.strip
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end


		sub_cats_present=false
		# puts type
		# if type != 'only_products'
			puts "finding subcats"
			cat.xpath('//div[@class="catalog-sections-list"]//a').each_with_index do |subcat, index|
				sub_cats_present=true
				break if Rails.env.development? && index>2
				has_subcat=true
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
					category.parent_id=id
					category.save!
				puts "process subcat"
				Ru4x4ProcessCategory(sub_url, category.id, :only_products)
			end
		# end

		if (next_url=cat.xpath('//a[@class="modern-page-next"]/@href').first) && !Rails.env.development? && !sub_cats_present
			Ru4x4ProcessCategory($base_url+next_url.content, id, :only_products)
		end

		# puts type
		if  !sub_cats_present && false# type != 'only_subcat'
			puts "finding products"		
			cat.xpath('//div[@class="catalog_item"]/div[@class="catalog_items_title"]/a/@href').each_with_index do |prod_link, index|
				break if Rails.env.development? && index>2
				puts prod_link
				next if prod_link == '/shop/farkopy/'
				prod = Nokogiri::HTML(open($base_url+prod_link+'?ncc=1'), nil)

				next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first || prod.xpath('//table[@class="offers_table"]').first

				sku=$sku_prefix + prod_link.content[/\/([^\/]+)\/$/,1]
				#prod.xpath('//span[@class="code"]').first.content
				product=Product.find_or_initialize_by(sku: sku)
			 	product.name=prod.xpath('//h1').first.content.strip
			 	puts product.name
			 	if descr=prod.xpath('//div[@class="catalog_element_text_description"]').first
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
					# prod.xpath("//h1").each { |div|  div.name= "p" }

					product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				# else
					# product.description=prod.xpath('//div[@class="desc"]/p').first.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				end

				if product.new_record?
				 	product.categories.clear
				 	product.categories << Category.find(id)
				 	product.sku=sku				
				end
	
				product.enabled=true
				product.save

				if prod.xpath('//table[@class="offers_table"]').first
					prod.xpath('//table[@class="offers_table"]//tr[position() mod 2 = 0]').each do |var|
						sku=$sku_prefix + var.xpath('td[2]').first.content.strip
						variant=product.variants.find_or_initialize_by(sku: sku)
						variant.name=var.xpath('td[1]').first.content.strip
						variant.enabled=true
						variant.availability='Доставка 2-3 дня'
						variant.price=var.xpath('td[4]').first.content.strip.delete(' ').delete("руб").to_i
						variant.save
					end
				else
					variant=product.variants.find_or_initialize_by(sku: sku)
					variant.sku=sku
					# next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first
					variant.price=prod.xpath('//span[@class="catalog_element_price_value"]/b').first.content.delete(' ').delete("руб").to_i
					variant.enabled = true
					variant.availability='Доставка 2-3 дня'
					variant.save
				end

				if product.images.count == 0 
					puts "findind images"
					prod.xpath('//a[@class="fancyImg"]/@href').each do |pic_url|
						# pic_url=pic_url.content.strip.gsub!(/^\/\//, 'http://')
						pic_url="#{$base_url}#{pic_url}"
						puts pic_url
						sleep 2
						begin
							image=product.images.new
							image.remote_image_url=pic_url
							image.save
						rescue Exception => e  
  							puts e.message  
							image.delete
						end
					end
					# prod.xpath('//a[@class="fancyImg"]/@href').each do |pic_url|
					# 	pic_url=pic_url.content.strip.gsub!(/^\/\//, 'http://')
					# 	puts pic_url
					# 	sleep 2
					# 	begin
					# 		image=product.images.new
					# 		image.remote_image_url=pic_url
					# 		image.save
					# 	rescue Exception => e  
  			# 				puts e.message  
					# 		image.delete
					# 	end
					# end
					# prod.xpath('//div[@class="catalog_element_photos clearfix"]/img/@src').each do |pic_url|
					# 	pic_url=pic_url.content.strip.gsub!(/^\/\//, 'http://')
					# 	puts pic_url
					# 	sleep 2
					# 	begin
					# 		image=product.images.new
					# 		image.remote_image_url=pic_url
					# 		image.save
					# 	rescue Exception => e  
  			# 				puts e.message  
					# 		image.delete
					# 	end
					# end
				end
				sleep 2
			end
		end
	end

	task :finalize_ru4x4 => :environment  do |task, args|
		# like_str=args.like_str || '%'
		c=Variant.where("updated_at < ?", 5.day.ago).update_all(availability: 'Нет в наличии', enabled: false)
		puts "Нет в наличии #{c}"

		Product.all.each do |prod|
			if prod.variants.enabled.empty?
				puts "товар #{prod.name} недоступен"
				prod.enabled=false
				prod.save
			end
		end
		
		Category.all.each do |cat|
			if cat.products.enabled.empty? and cat.categories.enabled.empty?
				cat.enabled=false
				cat.save			
			end
		end
	end
end