# coding: utf-8
namespace :import do
	task :ru4x4, [:url] => :environment do |task, args|

		$base_url='http://www.4x4ru.ru'
		$sku_prefix='ru_'

		if args.url 
			Ru4x4ProcessCategory(args.url, -1, 'only_subcat')			
		else			
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
				# category.parent_id=0
				# category.save!
			id=category.id
		end


		sub_cats_present=false
		puts "finding subcats"
		cat.xpath('//div[@class="catalog-sections-list"]//a').each_with_index do |subcat, index|
			sub_cats_present=true
			# break if Rails.env.development? && index>2
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
				# category.parent_id=id
				# category.save!
			puts "process subcat"
			Ru4x4ProcessCategory(sub_url, category.id, :only_products)
		end

		if (next_url=cat.xpath('//a[@class="modern-page-next"]/@href').first) && !Rails.env.development? && !sub_cats_present
			Ru4x4ProcessCategory($base_url+next_url.content, id, :only_products)
		end

		if  !sub_cats_present 
			puts "finding products"		
			cat.xpath('//div[@class="catalog_item"]/div[@class="catalog_items_title"]/a/@href').each_with_index do |prod_link, index|
				# break if Rails.env.development? && index>2
				puts prod_link
				next if prod_link == '/shop/farkopy/'
				prod = Nokogiri::HTML(open($base_url+prod_link+'?ncc=1'), nil)

				next unless prod.xpath('//span[@class="catalog_element_price_value"]/b').first || prod.xpath('//table[@class="offers_table"]').first

				sku=$sku_prefix + prod_link.content[/\/([^\/]+)\/$/,1]
				product=Product.find_or_initialize_by(sku: sku)
			 	product.name=prod.xpath('//h1').first.content.strip
			 	# puts product.name
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

					product.description=descr.to_s.encode('UTF-8', :invalid => :replace, :undef => :replace)
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
						process_attrs(variant.name, variant)
						variant.save
					end
				else
					variant=product.variants.find_or_initialize_by(sku: sku)
					variant.sku=sku
					variant.price=prod.xpath('//span[@class="catalog_element_price_value"]/b').first.content.delete(' ').delete("руб").to_i
					variant.enabled = true
					variant.availability='Доставка 2-3 дня'

					process_attrs(product.name, product)

					variant.save
				end

				if product.images.empty? && !Rails.env.development?
					puts "findind images"
					prod.xpath('//a[@class="fancyImg"]/@href').each do |pic_url|
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
		
				end
				# sleep 2
			end
		end
	end

	def process_attrs(name, variant)
		if name['Шина']						
			md= (/(\d+)[\/|X|х|*|"]+([\d|\.|,]+)(\s|R|D|\-|\*|\/|")+(\d+)/i.match(name))
			if md 
				w=md[1]
				h=md[2]
				wt='Ширина шины, мм'
				ht='Профиль %'
				if w.to_i<50
					w, h= h, w if w.to_i > h.to_i					
					w+='"'
					h+='"'
					wt='Ширина шины, дюйм'
					ht='Диаметр шины, дюйм'
				end
				w.gsub!(',', '.')
				w.gsub!('.50"', '.5"')
				w.gsub!('.0"', '"')
				w.gsub!('.00"', '"')
				h.gsub!(',', '.')
				h.gsub!('.50"', '.5"')
				h.gsub!('.0"', '"')
				h.gsub!('.00"', '"')
				w='275' if w=='772275'

				v=variant.attrs.find_or_initialize_by(name: wt)
				v.value=w
				v.save
				v=variant.attrs.find_or_initialize_by(name: ht)
				v.value=h
				v.save
				v=variant.attrs.find_or_initialize_by(name: 'Посадочный диаметр, дюйм')
				v.value=md[4]
				v.save
			else
				v=variant.attrs.find_or_initialize_by(name: wt)
				v.value='Неизвестно'
				v.save
				v=variant.attrs.find_or_initialize_by(name: ht)
				v.value='Неизвестно'
				v.save
				v=variant.attrs.find_or_initialize_by(name: 'Посадочный диаметр, дюйм')
				v.value='Неизвестно'
				v.save
			end

			md= (/(AT|A\/T|all-terrain|all terrain)/i.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'Класс шины')
				v.value='All Terrain'
				v.save
			else
				md= (/(MT|M\/T|mud-terrain|mud terrain|off road)/i.match(name))
				if md 
					v=variant.attrs.find_or_initialize_by(name: 'Класс шины')
					v.value='Mud Terrain'
					v.save
				else
					md= (/(simex|Silverstone|TSL|фбел|Extreme|XTREME)/i.match(name))
					if md 
						v=variant.attrs.find_or_initialize_by(name: 'Класс шины')
						v.value='Экстремальная'
						v.save
					else
						v=variant.attrs.find_or_initialize_by(name: 'Класс шины')
						v.value='Прочее'
						v.save
					end
				end
			end


		end


		if name['Диск']
			md= (/(14|15|16|17|18|20)\s*[xх*]\s*([\d|\.|\,]+)/i.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'Диаметр')
				v.value=md[1]
				v.save
				v=variant.attrs.find_or_initialize_by(name: 'Ширина')

				val=md[2]
				val.gsub!(/\,$/, '')
				val.gsub!(',', '.')
				val.gsub!(/\.0$/, '')
				v.value=val

				v.save
			else
				md= (/([\d|\.|\,]+)\s*[xх*]\s*R*(14|15|16|17|18|20)/i.match(name))
				if md 
					v=variant.attrs.find_or_initialize_by(name: 'Диаметр')
					v.value=md[2]
					v.save

					v=variant.attrs.find_or_initialize_by(name: 'Ширина')

					val=md[1]
					val.gsub!(/\,$/, '')
					val.gsub!(',', '.')
					val.gsub!('90', '9')
					val.gsub!(/\.0$/, '')
					v.value=val

					v.save
				else
					v=variant.attrs.find_or_initialize_by(name: 'Диаметр')
					v.value='Неизвестно'
					v.save
					v=variant.attrs.find_or_initialize_by(name: 'Ширина')
					v.value='Неизвестно'
					v.save
				end
			end
			
			md= (/(\s|\/)(\dH*\s*[xх*]\s*([\d|\.|\,]{3,}))/.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'Разболтовка')
				val=md[2]
				val.gsub!(/\,$/, '')
				val.gsub!(',', '.')
				val.gsub!('H', '')
				val.gsub!(/\.0$/, '')
				val.gsub!(/\s/, '')
				val.gsub!(/[xх*]/i, 'x')
				v.value=val
				v.save
			else
				v=variant.attrs.find_or_initialize_by(name: 'Разболтовка')
				v.value='Неизвестно'
				v.save
			end

			md= (/(бэдлок|бедлок|BeadLock)/i.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'BeadLock')
				v.value='Да'
				v.save
			else
				v=variant.attrs.find_or_initialize_by(name: 'BeadLock')
				v.value='Нет'
				v.save
			end

			md= (/ET(|:|\s)*(-*\d+)/i.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'Вылет')
				v.value=md[2]
				v.save
			else
				v=variant.attrs.find_or_initialize_by(name: 'Вылет')
				v.value='Неизвестно'
				v.save
			end

			md= (/D(|:|\s|-)*([\d|\.|\,]+)/i.match(name))
			if md 
				v=variant.attrs.find_or_initialize_by(name: 'Центральное отверстие')
				v.value=md[2]
				v.save
			else
				v=variant.attrs.find_or_initialize_by(name: 'Центральное отверстие')
				v.value='Неизвестно'
				v.save
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