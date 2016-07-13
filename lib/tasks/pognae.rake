# coding: utf-8
namespace :import do
	task :pognae => :environment do

		# $base_url='http://www.ellevill.org'
		$sku_prefix='pognae_'

		PognaeProcessCategory("http://pognaerussia.ru/catalog/%D0%A5%D0%B8%D0%BF%D1%81%D0%B8%D1%82%D1%8B-Pognae-No5", -1)
		PognaeProcessCategory("http://pognaerussia.ru/catalog/%D0%AD%D1%80%D0%B3%D0%BE-%D1%80%D1%8E%D0%BA%D0%B7%D0%B0%D0%BA%D0%B8-Pognae", -1)
		PognaeProcessCategory("http://pognaerussia.ru/catalog/Hipsity-Pognae-ORGA", -1)
		PognaeProcessCategory("http://pognaerussia.ru/catalog/%D0%A5%D0%B8%D0%BF%D1%81%D0%B8%D1%82%D1%8B-Pognae-%D0%9A%D0%BE%D0%BC%D0%BF%D0%BB%D0%B5%D0%BA%D1%82", -1)
		# PognaeProcessCategory("http://pognaerussia.ru/catalog/%D0%A5%D0%B8%D0%BF%D1%81%D0%B8%D1%82%D1%8B-Pognae-Smart", -1)
	end

	def PognaeProcessCategory(url, id)
		puts url
		cat = Nokogiri::HTML(open(url))

		if id==-1
			external_id=$sku_prefix + url[/\/([^\/]+)$/,1]
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=cat.xpath('//title').first.content.strip
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end

		cat.xpath('//div[@class="prod_hold"]//div[@class="image goods-cat-image-medium-square"]/a/@href').each do |prod_link|
			puts prod_link
			prod = Nokogiri::HTML(open(prod_link))

			# next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first || prod.xpath('//table[@class="offers_table"]').first

			sku=$sku_prefix + prod_link.content[/\/([^\/]+)$/,1]
			sku.gsub!('%D0%A5%D0%B8%D0%BF%D1%81%D0%B8%D1%82-Pognae-', '')
			sku.gsub!('-Pognae', '')

			puts sku
			#prod.xpath('//span[@class="code"]').first.content
			product=Product.find_or_initialize_by(sku: sku)
			if product.new_record?
			 	product.name=prod.xpath('//h1').first.content.strip
			 	puts product.name
			 	product.categories.clear
			 	product.categories << Category.find(id)
			 	product.sku=sku				
				# 	descr.css('img').each do |img|
				# 		url=img.attr('src')
				# 		unless image=DescriptionImage.find_by(original_url: url)
				# 			image=DescriptionImage.new
				# 			image.original_url=url
				# 			# url=url[/^\.\.(.*)$/,1] if url.start_with?('..')
				# 			url = "#{$base_url}#{url}" unless url.start_with?($base_url)
				# 			image.remote_image_url=url
				# 			image.save
				# 		end
				# 		img.attributes['src'].value=image.image.url					
				# 	end
				# 	product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				# end
			end

			descr=prod.xpath('//div[@id="idTab1"]').first
			descr.xpath('h3').remove
			descr.xpath('div[@class="htmlDataBlock"]').remove
			descr.xpath('//@style').remove
			# descr.xpath('//a').remove
			descr.xpath("//em").each { |em|  em.name= "span"; em.set_attribute("class" , "title") }

		 	product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)

			variant=product.variants.find_or_initialize_by(sku: sku)
			variant.price=prod.xpath('//span[@class="price-new goodsDataMainModificationPriceNow"]//span[@class="num"]').first.content.strip.delete("\s").to_i
			
			if prod.xpath('//span[@itemprop="availability" and @content="in_stock"]').length > 0
				product.enabled=true
				variant.enabled=true
				variant.availability='Доставка 3-4 дня'
			else
				product.enabled=false
				variant.enabled=false
				variant.availability='Нет в наличии'
			end

			product.save
			variant.save					


			if product.images.count == 0 
				puts "try to get images"
				prod_images=prod.xpath('//div[@class="image-additional"]/a/@href')
				prod_images.each do |pic_url|
					# sleep 3
					puts pic_url
					begin
						image=product.images.new
						image.remote_image_url=pic_url
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