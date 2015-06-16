# coding: utf-8
namespace :import do
	task :yml, [:supplier]=> :environment do |task, args|

		supplier=args.supplier

		skip_cats=[]
		skip_cats=[1000003, 1000004, 1000005, 1000006, 1000007, 1000008, 1000009, 1000010, 1000011, 1000012, 1000013, 1000014, 1000015, 1000016, 1000017, 1000018, 1000019, 1000020, 1000021, 1000022, 1000023, 1000024, 1000025, 1000026, 1000027, 1000028, 1000029, 1000030, 1000031, 1000032, 1000033, 1000034, 1000035, 1000037, 1000038, 1000039, 1000040, 1000041, 1001000, 1001001, 1001002, 1001003, 1001004, 1001005, 1001006, 1001007, 1001008, 1001009]  if supplier == '220'
		skip_cats=[246] if supplier == 'camp'
		skip_cats=[300] if supplier == 'nova'
		skip_cats=[752,567,783,983,1055,573,1716,681,678,575,1442,1155,985,1362,1361,1676,691,690,794,607,610,608,613,619,626,1563,560,647,552,527,998,801,803,809,811,1386,1065,838,1032,910,845,862,858,1118,868,998,868] if supplier == 'salmo'

		start_time=Time.now
		loaded_images=[]

		if Rails.env == 'production'
			url='http://www.novatour.ru/Services/ShopService/YMLGet?region=1608' if supplier == 'nova'
			url='http://www.camping.ru/prices/yandex.php' if supplier == 'camp'
			url='http://www.salmoru.com/yandexshop.xml' if supplier == 'salmo'
			url='http://www.220-volt.ru/xml/hw.xml' if supplier == '220'

			yml = Nokogiri::XML(open(url))
		else
			yml = Nokogiri::XML(open("tmp/yml/#{supplier}.yml"))
		end

		yml.xpath('//categories/category').each do |node|
			parent_id=node.attr('parentId')
			id=node.attr('id')

			skip_cats << id if skip_cats.include?(parent_id.to_i)
			if skip_cats.include?(id.to_i)
				if category=Category.find_by(external_id: "#{supplier}_#{id}")
					category.products.delete_all
					category.delete
				end
				next
			end

			name=node.content.strip
			if supplier == 'salmo'
				name.gsub!(/^(\d|\.)*\s/, '')
				name=name.mb_chars.capitalize
			end

			category=Category.find_or_initialize_by(external_id: "#{supplier}_#{id}")
			if category.new_record?
				category.parent=Category.find_by(external_id: "#{supplier}_#{parent_id}") if parent_id
				category.name=name
				category.external_id="#{supplier}_#{id}"
				puts category.name
				category.enabled=true
				category.save!
			end
		end

		yml.xpath('//offers/offer').each do |node|
			cat_id=node.xpath('categoryId').first.content
			next if skip_cats.include?(cat_id.to_i)

			id=node.attr('id')
			
			vendorCode=node.xpath('vendorCode').first.content if node.xpath('vendorCode').first
#			vendorCode|=node.articul.content if node.articul

			manufacturer=node.xpath('vendor').first.content

			sku="#{supplier}_#{id}"
			sku="nova_#{manufacturer}.#{vendorCode}" if supplier == 'nova'

			product=Product.find_or_initialize_by(sku: sku)
			if (supplier == 'camp')
				product.name=node.xpath('typePrefix').first.content.gsub(/\&amp\;quot\;/, '"').gsub(/\&quot\;/, '"')
			elsif supplier == 'salmo'
				product.name=node.xpath('name').first.content				
			else
				product.name=node.xpath('model').first.content
			end
			
			puts product.name
			product.categories.clear
			product.categories << Category.find_by(external_id: "#{supplier}_#{cat_id}")
			product.sku=sku

			product.save!

			product.attrs.delete_all
			node.xpath("param").each do |param|
				if param['name'] != 'Цвет' && param['name'] != 'Размер' 
					if param.content == 'true'
						product.attrs.create(name: param['name'], value: 'Да')
					elsif param.content == 'false'
						product.attrs.create(name: param['name'], value: 'Нет')
					elsif param.content!=''
						product.attrs.create(name: param['name'], value: param.content)
					end
				end
			end

			color=node.xpath("param[@name='Цвет']").first.content if node.xpath("param[@name='Цвет']").first
			size=node.xpath("param[@name='Размер']").first.content if node.xpath("param[@name='Размер']").first

			variant_sku=node.xpath('barcode').first.content if node.xpath('barcode').first
			if not variant_sku
				variant_sku=sku
				variant_sku+=".#{color}" if color
				variant_sku+=".#{size}" if size
			end
			variant_name=product.name
			variant_name+=" цвет #{color}" if color
			variant_name+=" размер #{size}" if size		

			variant=product.variants.find_or_initialize_by(sku: variant_sku)
			variant.sku=variant_sku
			variant.name=variant_name
			price=node.xpath('price').first.content
			price.gsub!(/,/, '')
			variant.price=price
			variant.enabled=true

			variant.availability='Доставка 2-7 дней' if supplier=='nova'
			variant.availability='Доставка 7 дней' if supplier=='camp'
			variant.availability='Доставка 14 дней' if supplier=='salmo'

			variant.attrs.find_or_initialize_by(name: 'Цвет').update(value: color) if color
			variant.attrs.find_or_initialize_by(name: 'Размер').update(value: size) if size

			variant.save!

			product.description=node.xpath('description').first.content if node.xpath('description').first
			product.enabled=true

			product.save!

			if product.images.count == 0
#				product.images.where("created_at < :start_time", {start_time: start_time}).delete_all
				node.xpath('picture').each do |pic|
					pic_url=pic.content
					pic_url.gsub!('http://www.220-volt.ru', '') if supplier == '220'
					if not loaded_images.include?(pic_url)
						begin
							puts pic_url
							loaded_images << pic_url

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
# #	my $price=$offer->findvalue('price');
# 	my $price=($offer->findnodes('price'))[0]->toString;
# 	$price=~s/\<price\>(.*)\<\/price\>/$1/;
# 	$price=~s/,//;

	
# 	while ($name=~s/"/&quot;/g){};


# 	my $length=$offer->findvalue('extprops/length'); #для рыболов-сервис импортируем длину
# 	my $width=$offer->findvalue('extprops/width'); #для рыболов-сервис импортируем ширину
# 	my $height=$offer->findvalue('extprops/height'); #для рыболов-сервис импортируем высоту
# #       my $weight=$offer->findvalue('extprops/weight'); #для рыболов-сервис импортируем вес
# 	my $points=$price-1;
# 	my $points2=ceil($price*0.02);


# 		end


# 				cat.xpath('//div[@class="b-product-list-item__title"]/a').each do |prod_item|
# 					name=prod_item.content.strip
# #					next if not (name.index('DOD') or name.index('КАРКАМ') or name.index('Sho-Me')or name.index('Crunch')or name.index('Whistler')or name.index('Garmin')or name.index('Navitel')or name.index('парктроник')or name.index('Sheriff')or name.index('StarLine')or urls[url]==5)
# #					name.gsub!('антирадар', 'Радар-детектор')
# 					puts "#{name}"
# 					prod_url=prod_item['href']
# 					prod = Nokogiri::HTML(open("http://www.ulmart.ru#{prod_url}"))
# 					sku=prod.xpath('//span[@class="b-art"]/span').first.content
# 					descr=prod.xpath('//section[@id="properties_full"]').to_html
# 					price=prod.xpath('//div[@class="b-product-card__price"]/span/span[1]').first.content;
# 					price.gsub!(/[[:space:]]/, '')

# 					product=Product.find_or_create_by(name: name)
# 					product.name=name
# 					product.description=descr
# 					product.categories << Category.find(urls[url])

# 					# Manufacturer.all.each do |man|
# 					# 	if name.include?(man.name)
# 					# 		product.manufacturer=man
# 					# 	end
# 					# end

# 					product.save
# #					if product.new_record?
# 						product.images.clear
# 						image=product.images.new
# 						image.remote_image_url="http://fast.ulmart.ru/good_pics/#{sku}.jpg"
# 						image.save!
# #					end
# 				end
# 				break if cat.xpath('//div[@id="hide-show-more-lnk"]').first.content.to_i<=0
# 				page=page+1
# 			end
# 		end
# 	#	Product.where('updated_at < ?', 20.minutes.ago).update_all(hidden:true)
	end
end