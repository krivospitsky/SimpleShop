# coding: utf-8
namespace :import do
	task :sport4x4 => :environment do
		Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html", nil)
		# Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=128", -1, :only_subcat)
		# Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=2", -1, :only_subcat)
		# Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=8", -1, :only_subcat)
		# Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=793", -1, :only_subcat)
		# Sport4x4ProcessCategory("http://www.4x4sport.ru/catalogue.html?gr=456", -1, :only_subcat)
		
	end

	def Sport4x4ProcessCategory(url, parent_id)
		return if ['http://www.4x4sport.ru/catalogue.html?gr=789', 'http://www.4x4sport.ru/publications.html?publications=publications4', 'http://www.4x4sport.ru/catalogue.html?gr=1417', 'http://www.4x4sport.ru/catalogue.html?gr=1245', 'http://www.4x4sport.ru/catalogue.html?gr=1111'].include?(url)
		puts url
		if url=="http://www.4x4sport.ru/catalogue.html"
			cat = Nokogiri::HTML(open(url))
		else
			cat = Nokogiri::HTML(open(url+'&full=1'))
		end

		if url!="http://www.4x4sport.ru/catalogue.html"
			external_id="s4x4_" + url[/=(\d+)$/,1]
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=cat.xpath('//h1[@class="great"]').first.content.strip
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.parent_id=parent_id
			puts 'cat save'
				category.save!
			end
			id=category.id
		else
			id=nil
		end

		has_subcat=false
		puts 'subcats'
		cat.xpath('//div[@class="groupitem"]/a').each do |subcat|
			has_subcat=true
			sub_url=subcat.attr('href')
			sub_url='http://www.4x4sport.ru'+sub_url if !sub_url.starts_with?('http://')
			Sport4x4ProcessCategory(sub_url, id)
		end

		if has_subcat==false
			cat.xpath('//div[@class="item"]/a/@href').each do |prod_link|
				puts prod_link
				prod = Nokogiri::HTML(open('http://www.4x4sport.ru'+prod_link), nil)
				sku='s4x4_'+prod.xpath('//div[@class="itemparams"][1]/p[1]/span').first.content.strip

				product=Product.find_or_initialize_by(sku: sku)

			 	product.name=prod.xpath('//h1[@class="great"]').first.content.strip
			 	puts product.name
			 	product.categories.clear
			 	product.categories << Category.find(id)
			 	product.sku=sku				
			 	if descr=prod.xpath('//div[@id="divdesc"]').first
					descr.css('img').each do |img|
						url=img.attr('src')
						unless image=DescriptionImage.find_by(original_url: url)
							image=DescriptionImage.new
							url=url[/^\.\.(.*)$/,1] if url.start_with?('..')
							url = "http://www.4x4sport.ru#{url}" unless url.start_with?('http://www.4x4sport.ru')
							image.remote_image_url=url
							image.save
						end
						img.attributes['src'].value=image.image.url if img.attributes['src']
					end
					prod.xpath("//h1").each { |div|  div.name= "p" }

					product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				else
					product.description=prod.xpath('//div[@class="desc"]/p').first.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
				end
				product.enabled=true
				product.save

				variant=product.variants.find_or_initialize_by(sku: sku)
				variant.sku=sku
				variant.price=prod.xpath('//span[@class="price"]').first.content.delete(' ').delete("руб.").to_i
				variant.enabled = true
				variant.availability='Доставка 2-3 дня'
				variant.save

				if product.images.count == 0 
					prod.xpath('//img[@itemprop="image"]/@src').each do |pic_url|
						begin
							image=product.images.new
							image.remote_image_url='http://www.4x4sport.ru'+pic_url
							image.save
						rescue
							image.delete
						end
					end
				end
				sleep(1)
			end
		end
	end

	def Sport4x4ProcessProduct(url)
	end
end