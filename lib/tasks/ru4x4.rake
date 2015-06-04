# coding: utf-8
namespace :import do
	task :ru4x4 => :environment do

		$base_url='http://www.4x4ru.ru'
		$sku_prefix='ru_'

		# Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/bagazhniki/", -1, :only_subcat)
		# Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/bampera_i_farkopy/", -1, :only_subcat)
		# Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/porogi_silovye/", -1, :only_subcat)
		# Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/silovaya_zashchita/", -1, :only_subcat)

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/diski_kolyesnye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/shiny/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/deflyatory/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/tayrloki/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/prostavki_kolyesnye_/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/tsepi_i_braslety_protivoskolzheniya/", -1, :only_subcat)

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/lebyedki_avtomobilnye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/lebyedki_dlya_atv_i_snegokhodov/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/lebyedki_perenosnye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/oborudovanie_dlya_lebedok/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/trosa_sinteticheskie/", -1, :only_subcat)

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/podveska/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/amortizatory_rancho/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dempfery_rulevoe/", -1, :only_subcat)

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/akkumulyatory_gelevye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/zaryadnye_ustroystva/", -1, :only_subcat)

		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_atv/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_nivy_i_shevi_nivy/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dlya_uaz_1/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/domkraty_i_aksessuary/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/dopolnitelnyy_svet/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/kanistry_ekspeditsionnye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/kompressory/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/konsoli_potolochnye/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/aksessuary-dlya-pikapov/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/benzobaki_uvelichennoy_yemkosti/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/blokirovki/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/podogrevateli_dvigatelya_dizelnogo_topliva/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/rasshiriteli_arok/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/stropy_i_takelazh/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/send_traki/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/tovary_dlya_turizma/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/universalnye_krepleniya_quick_fist_samokhvat/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/khaby_kolyesnye_/", -1, :only_subcat)
		Ru4x4ProcessCategory("http://www.4x4ru.ru/shop/shnorkeli/", -1, :only_subcat)

		# http://www.4x4ru.ru/shop/shturmanskoe_oborudovanie/
		# http://www.autoventuri.ru/catalog-bodi_lift/brand-rif/
		# вент, генератор, хабы		
	end

	def Ru4x4ProcessCategory(url, id, type)
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

		# has_subcat=false
		cat.xpath('//div[@class="catalog_section_list"]//a[@class="section_title"]').each do |subcat|
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

			Ru4x4ProcessCategory(sub_url, category.id, :only_products)
		end

		# if has_subcat==false
			cat.xpath('//div[@class="catalog_item"]/div[@class="catalog_items_title"]/a/@href').each do |prod_link|
				next if prod_link == '/shop/farkopy/'
				prod = Nokogiri::HTML(open($base_url+prod_link), nil)
				puts prod_link
				next if prod.xpath('//table[@class="offers_table"]').first
				sku=$sku_prefix + prod_link.content[/\/([^\/]+)\/$/,1]
				#prod.xpath('//span[@class="code"]').first.content
				product=Product.find_or_initialize_by(sku: sku)

			 	product.name=prod.xpath('//h1').first.content.strip
			 	puts product.name
			 	product.categories.clear
			 	product.categories << Category.find(id)
			 	product.sku=sku				
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
				product.enabled=true
				product.save

				variant=product.variants.find_or_initialize_by(sku: sku)
				variant.sku=sku
				variant.price=prod.xpath('//span[@class="catalog_element_price_value"]/b').first.content.delete(' ').delete("руб").to_i
				variant.enabled = true
				variant.availability='Доставка 2-3 дня'
				variant.save

				if product.images.count == 0 
					prod.xpath('//a[@class="fancyImg"]/@href').each do |pic_url|
						begin
							image=product.images.new
							image.remote_image_url=$base_url+pic_url
							image.save
						rescue
							image.delete
						end
					end
					prod.xpath('//img[@width=500]/@src').each do |pic_url|
						begin
							image=product.images.new
							image.remote_image_url=$base_url+pic_url
							image.save
						rescue
							image.delete
						end
					end
				end
				sleep 2
			end
		# end
	end
end