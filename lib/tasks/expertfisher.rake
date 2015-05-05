# coding: utf-8
namespace :import do
	task :expertfisher => :environment do
		ProcessCategory("http://expertfisher.ru/CatalogCategoryRl.aspx")
#		ProcessCategory("http://expertfisher.ru/category-r/13-0-0-primanki.aspx")

	end

	def ProcessCategory(url)
		skip_cat=['347-60-0-vobliery-raid', '187-0-0-spinnierbieity-i-bazzbieity', '163-1-0-lieski-plietienyie-shnury-pontoon21', '223-31-0-kriuchki-s-povodkom-i-osnastki-ownercultiva', '90-33-0-svietliachki-briscola', '196-1-0-viertliuzhki-i-karabiny-pontoon21', '331-54-0-viertliuzhki-i-karabiny-axis', '384-54-0-povodki-axis', '304-6-0-aksiessuary-cf-design', '393-61-0-podsaki-snowbee', '373-61-0-zhiliety-snowbee', '369-61-0-kurtki-i-briuki-snowbee', '374-0-0-pierchatki', '73-33-0-nabory-antienn-briscola', '298-0-0-sumki', '296-0-0-iashchiki-i-chiemodany', '117-5-0-nakhlystovyie-udilishcha-banax', '121-0-0-iskusstviennyie-mushki']
		cat = Nokogiri::HTML(open(url))
		curr_ext_id=url[/\/([^\/]+?)\.aspx/,1]

		cat.xpath('//div[@class="rounded-white"]/div[@class="body"]/a').each do |subcat|
			sub_url=subcat.attr('href')
			ext_id=sub_url[/\/([^\/]+?)\.aspx/,1]
			
			if skip_cat.include?(ext_id)
				if category=Category.find_by(external_id: ext_id)
					category.products.delete_all
					category.delete
				end
				next
			end

			category=Category.find_or_initialize_by(external_id: ext_id)
			if category.new_record?
				category.parent=Category.find_by(external_id: curr_ext_id) if curr_ext_id
				category.external_id=ext_id
				category.name=subcat.xpath('h4').first.content
				puts category.name
				category.enabled=true
				category.save!
			end

			ProcessCategory(sub_url)
		end

		cat.xpath('//td[@class="item"]/div/a/@href').each do |prod_link|
			prod = Nokogiri::HTML(open(prod_link))
			sku = 'expertfisher_'+prod_link.content[/\/([^\/]+?)\.aspx/, 1]
			product=Product.find_or_initialize_by(sku: sku)

			product.name=prod.xpath('//div[@class="block description clearfix"]/h1').first.content
			puts product.name
			product.categories.clear
			product.categories << Category.find_by(external_id: curr_ext_id)
			product.sku=sku
			if descr=prod.xpath('//div[@class="block description clearfix"]').first
				descr.xpath('h1').remove
				img_o=descr.xpath('div[@id="ctl00_ctl00_cph1_cphLeft_ctrlProductDescription_teaserPanel"]')
				img_str=img_o.first.content if img_o.first
				descr.xpath('div[@id="ctl00_ctl00_cph1_cphLeft_ctrlProductDescription_teaserPanel"]').remove
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
				product.description=descr.to_s 
			end
			product.enabled=true

			attr_names=[]
			prod.xpath('id("ctl00_ctl00_cph1_cphLeft_ProductVariantList_pnlMain")/div[3]/table/tr').first.xpath('th')[3..-4].each do  |attr_name|
				attr_names<<attr_name.content.strip
			end

			prod.xpath('id("ctl00_ctl00_cph1_cphLeft_ProductVariantList_pnlMain")/div/table/tr')[1..-1].each do |var|
				if var.xpath('td').first
					variant_sku=var.xpath('td[3]/b').first.content
					variant=product.variants.find_or_initialize_by(sku: variant_sku.strip) unless variant=product.variants.find_by(sku: variant_sku)

					 
						variant.sku=variant_sku.strip
						variant.price=var.xpath('td[last()-2]/b').first.content.delete(' ').gsub(/[[:space:]]/,'')
						variant.enabled = true
						variant.availability='Доставка 2-3 дня'
						i=0
						variant.attr={}
						var.xpath('td')[3..-4].each do |attrib|
							variant.attr[attr_names[i]]=attrib.content.strip
							i+=1
						end

						if !variant.image?
							if img=var.xpath('td[2]//img').first
								pic_url=img.attr('src')
								variant.remote_image_url=pic_url
							end
						end
						variant.name=nil
					if variant.new_record?
					end
					variant.save!
				end
			end				
			product.save!

			if product.images.count == 0 && img_str
				img_str.scan(/push\('(.+?)'/).each do |pic|
					pic_url=pic[0]
					begin
						image=product.images.new
						image.remote_image_url=pic_url
						image.save
					rescue
						image.delete
					end
				end
			end
		end
	end
end