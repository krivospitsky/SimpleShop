# coding: utf-8
namespace :import do
	task :gefest => :environment do

		$base_url='http://gefest.by'
		$sku_prefix=''

		GefestProcessCategory("http://gefest.by/catalogue/gas-ovens/60x060/", -1, :only_subcat, 'Размер стола 60х60')
		GefestProcessCategory("http://gefest.by/catalogue/gas-ovens/50x57/", -1, :only_subcat, 'Размер стола 50х57-58.5')
		GefestProcessCategory("http://gefest.by/catalogue/electrical-ovens/60x60/", -1, :only_subcat, 'Размер стола 60х60')
		GefestProcessCategory("http://gefest.by/catalogue/electrical-ovens/50x57/", -1, :only_subcat, 'Размер стола 50х57-58,5')
		GefestProcessCategory("http://gefest.by/catalogue/gas-electric-ovens/50x53/", -1, :only_subcat, 'Размер стола 50х57-58,5')
		GefestProcessCategory("http://gefest.by/catalogue/gas-electric-ovens/60x60/", -1, :only_subcat, 'Размер стола 60х60')
		GefestProcessCategory("http://gefest.by/catalogue/embedded/gaspanel/", -1, :only_subcat, 'Газовые панели')
		GefestProcessCategory("http://gefest.by/catalogue/embedded/electropanel/", -1, :only_subcat, 'Электрические панели')
		GefestProcessCategory("http://gefest.by/catalogue/embedded/electrooven//", -1, :only_subcat, 'Электрические духовки')
		GefestProcessCategory("http://gefest.by/catalogue/table-ovens/", -1, :only_subcat, 'Настольные плиты')
		GefestProcessCategory("http://gefest.by/catalogue/air-cleaners/60/", -1, :only_subcat, 'Ширина 60')
		GefestProcessCategory("http://gefest.by/catalogue/air-cleaners/50/", -1, :only_subcat, 'Ширина 50')
	end

	def GefestProcessCategory(url, id, type, name='')
		cat = Nokogiri::HTML(open(url))

		if id==-1
			external_id=Digest::MD5.hexdigest(url)
			category=Category.find_or_initialize_by(external_id: external_id)
			if category.new_record?
				category.name=name
				category.external_id=external_id
				puts category.name
				category.enabled=true
				category.save!
			end
			id=category.id
		end

		if type==:only_subcat
			cat.xpath('//td[@class="in_left"]/ul/ul/ul/li/a').each do |subcat|
				sub_url=$base_url+subcat.attr('href')
				puts sub_url
				external_id=Digest::MD5.hexdigest(sub_url)

				category=Category.find_or_initialize_by(external_id: external_id)
				if category.new_record?
					category.parent_id=id
					category.external_id=external_id
					category.name=subcat.content.strip
					puts category.name
					category.enabled=true
					category.save!
				end

				GefestProcessCategory(sub_url, category.id, :only_products)
			end
		end

			# if next_url=cat.xpath('//a[@class="modern-page-next"]/@href').first
			# 	GefestProcessCategory($base_url+next_url.content, id, :only_products)
			# end

		if type==:only_products
			cat.xpath('//table[@id="cataloque_all"]//p/a/@href').each do |prod_link|
				prod = Nokogiri::HTML(open($base_url+prod_link), nil)

				# next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first || prod.xpath('//table[@class="offers_table"]').first

				puts prod_link
				name=prod.xpath('//h1').first.content.strip
				name.gsub!('Только экспортное предложение.', '')
				sku=name
				sku.gsub!(/(\(.*\))/, '')

				#prod.xpath('//span[@class="code"]').first.content
				product=Product.find_or_initialize_by(sku: sku)
				if product.new_record?
				 	product.name=name
				 	puts product.name
				 	product.categories.clear
				 	product.categories << Category.find(id)
				 	product.sku=sku				
				 	if descr=prod.xpath('//td[@class="content"]/p[2]').first
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

				product.attrs.destroy_all
				prod.xpath('//table[@id="catalogue"]//td[@width="100%"]//tr').each do |attr_row|
					if td1=attr_row.xpath('td[1]').first
						name=td1.content.strip
						if name[-1]==':'
							attr=product.attrs.new
							attr.name=name[0..-2]
							attr.name='Мощность передней левой горелки' if attr.name=='Передняя левая'
							attr.name='Мощность передней правой горелки' if attr.name=='Передняя правая'
							attr.name='Мощность задней левой горелки' if attr.name=='Задняя левая'
							attr.name='Мощность задней правой горелки' if attr.name=='Задняя правая'
							attr.value=attr_row.xpath('td[2]').first.content.strip
							attr.value='+' if attr.value.blank?
							attr.save
						end
					end
				end
				prod.xpath('//table[@id="catalogue"]//td[@width="100%"]//tr/td//td[@width="100%"]').each do |attr_row|
					attr=product.attrs.new
					attr.name=attr_row.content.strip
					attr.value='+'
					attr.save
				end



				variant=product.variants.find_or_initialize_by(sku: sku)
				variant.enabled=true
				variant.price=0
				variant.sku=sku
				variant.availability='Доставка 7 дней'
				variant.save


				if product.images.count == 0 
					prod_images=prod.xpath('//a[@rel="lightbox"]/@href')
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