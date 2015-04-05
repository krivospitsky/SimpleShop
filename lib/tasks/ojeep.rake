# coding: utf-8
namespace :ojeep do
	task :import => :environment do
		OJProcessCategory("http://ojeep.ru/shmurdyak/332/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/347/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/334/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/329/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/330/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/354/", -1, :only_subcat)
		OJProcessCategory("http://ojeep.ru/shmurdyak/331/", -1, :only_subcat)
	end

	def OJProcessCategory(url, id, type)
		cat = Nokogiri::HTML(open(url))

		if id==-1
			sku="oj_" + url[/\/(\d+)\/$/,1]
			category=Category.find_or_initialize_by(external_id: sku)
			if category.new_record?
				category.name=cat.xpath('//h1[@id="pagetitle"]').first.content			
				category.external_id=sku
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end

		has_subcat=false
		cat.xpath('(//li[@class="selected"])[last()]/ul/li/a').each do |subcat|
			has_subcat=true
			sub_url='http://ojeep.ru'+subcat.attr('href')
			ext_id="oj_" + sub_url[/\/(\d+)\/$/,1]
		
			category=Category.find_or_initialize_by(external_id: ext_id)
			if category.new_record?
				category.parent_id=id
				category.external_id=ext_id
				category.name=subcat.content
				puts category.name
				category.enabled=true
				category.save!
			end

			ProcessCategory(sub_url, category.id, :only_products)
		end

		if has_subcat==false
			cat.xpath('//div[@class="catname"]/a/@href').each do |prod_link|
				prod = Nokogiri::HTML(open('http://ojeep.ru'+prod_link), nil, 'WINDOWS-1251')
				sku="oj_" + prod_link.content[/\/(\d+)\/$/,1]
				product=Product.find_or_initialize_by(sku: sku)

			 	product.name=prod.xpath('//h1[@id="pagetitle"]').first.content
			 	puts product.name
			 	product.categories.clear
			 	product.categories << Category.find(id)
			 	product.sku=sku
			 	if descr=prod.xpath('//div[@class="catalog-element"]').first
			 		img_o=descr.xpath('//table[@class="images_top"]')
			 		img_str=img_o.first.to_s if img_o.first

			 		price=descr.xpath('//span[@class="catalog-price"]').first.content.delete(' ').delete("руб.").to_i
			 		puts price

			 		descr.xpath('div[@class="properti"]').remove
			 		descr.xpath('p[@class="price_base"]').remove
			 		descr.xpath('noindex').remove
			 		descr.xpath('table[@class="images_top"]').remove
					descr.css('img').each do |img|
						url=img.attr('src')
						unless image=DescriptionImage.find_by(original_url: url)
							image=DescriptionImage.new
							url = "http://expertfisher.ru#{url}" unless url.start_with?('http://expertfisher.ru')
							image.remote_image_url=url
							image.save
						end
						img.attributes['src'].value=image.image.url					
					end
					product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
					#puts descr.to_s 
				end
				product.enabled=true

				variant=product.variants.find_or_initialize_by(sku: sku)
				variant.sku=sku
				variant.price=price
				variant.enabled = true
				variant.availability='Доставка 2-3 дня'
				variant.save!

				product.save!

			# 	attr_names=[]
			# 	prod.xpath('id("ctl00_ctl00_cph1_cphLeft_ProductVariantList_pnlMain")/div[3]/table/tr').first.xpath('th')[3..-4].each do  |attr_name|
			# 		attr_names<<attr_name.content.strip
			# 	end

			# 	prod.xpath('id("ctl00_ctl00_cph1_cphLeft_ProductVariantList_pnlMain")/div/table/tr')[1..-1].each do |var|
			# 		if var.xpath('td').first
			# 			variant_sku=var.xpath('td[3]/b').first.content
			# 			variant=product.variants.find_or_initialize_by(sku: variant_sku.strip) unless variant=product.variants.find_by(sku: variant_sku)

						 
			# 				variant.sku=variant_sku.strip
			# 				variant.price=var.xpath('td[last()-2]/b').first.content.delete(' ').gsub(/[[:space:]]/,'')
			# 				variant.enabled = true
			# 				variant.availability='Доставка 2-3 дня'
			# 				i=0
			# 				variant.attr={}
			# 				var.xpath('td')[3..-4].each do |attrib|
			# 					variant.attr[attr_names[i]]=attrib.content.strip
			# 					i+=1
			# 				end

			# 				if !variant.image?
			# 					if img=var.xpath('td[2]//img').first
			# 						pic_url=img.attr('src')
			# 						variant.remote_image_url=pic_url
			# 					end
			# 				end
			# 				variant.name=nil
			# 			if variant.new_record?
			# 			end
			# 			variant.save!
			# 		end
			# 	end				

				if product.images.count == 0 && img_str
					img_str.scan(/src="(.+?)"/).each do |pic|
						pic_url=pic[0]
						begin
							image=product.images.new
							image.remote_image_url='http://ojeep.ru'+pic_url
							image.save
						rescue
							image.delete
						end
					end
				end
			end
		end
	end
end