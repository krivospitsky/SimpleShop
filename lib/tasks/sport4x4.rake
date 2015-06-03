# coding: utf-8
namespace :import do
	task :sport4x4 => :environment do
		Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=128", -1, :only_subcat)
	end

	def Sport4x4ProcessCategory(url, id, type)
		cat = Nokogiri::HTML(open(url))

		if id==-1
			external_id="s4x4_" + url[/=(\d+)$/,1]
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=cat.xpath('//h1[@class="c"]').first.content.strip
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end

		has_subcat=false
		cat.xpath('//div[@class="catalogue"]/div/div/a').each do |subcat|
			has_subcat=true
			sub_url='http://www.4x4sport.ru'+subcat.attr('href')
			external_id="s4x4_" + sub_url[/=(\d+)$/,1]

			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.parent_id=id
				category.external_id=external_id
				category.name=subcat.xpath('span').first.content.strip
				puts category.name
				category.enabled=true
				category.save!
			end

			Sport4x4ProcessCategory(sub_url, category.id, :only_products)
		end

		if has_subcat==false
			cat.xpath('//div[@class="good"]//a[@class="title"]/@href').each do |prod_link|
				prod = Nokogiri::HTML(open('http://www.4x4sport.ru'+prod_link), nil)
				sku="s4x4_" + prod.xpath('//span[@class="code"]').first.content
				product=Product.find_or_initialize_by(sku: sku)

			 	product.name=prod.xpath('//div[@class="desc"]/h1').first.content.strip
			 	puts product.name
			 	product.categories.clear
			 	product.categories << Category.find(id)
			 	product.sku=sku				
			 # 	if descr=prod.xpath('//div[@id="divdesc"]').first
				# 	descr.css('img').each do |img|
				# 		url=img.attr('src')
				# 		unless image=DescriptionImage.find_by(original_url: url)
				# 			image=DescriptionImage.new
				# 			url = "http://www.4x4sport.ru/#{url}" unless url.start_with?('http://www.4x4sport.ru')
				# 			image.remote_image_url=url
				# 			image.save
				# 		end
				# 		img.attributes['src'].value=image.image.url					
				# 	end
				# 	product.description=descr.to_s
				# else
				# 	product.description=prod.xpath('//div[@class="//desc/p"]').first.to_s
				# end
				product.enabled=true

				variant=product.variants.find_or_initialize_by(sku: sku)
				variant.sku=sku
				variant.price=prod.xpath('//span[@class="price"]').first.content.delete(' ').delete("руб.").to_i
				variant.enabled = true
				variant.availability='Доставка 2-3 дня'
				# variant.attr={}
				variant.save
				product.save
			end
		end
	end
end