# coding: utf-8

require 'zip'


namespace :import do
	task :netlab do 

		skip_cats=[15,197979,278068,4978,4986]

		start_time=Time.now
		loaded_images=[]

		Zip::File.open(open("http://www.netlab.ru/products/pricexml4.zip")) do |zipfile|
		  	zipfile.each do |file|
				pricexml = Nokogiri::XML(file)
		  	end
		end
		
# 		while (!$last)
# {
        $last=1;
        pricexml.xpath('/xml_catalog/shop/categories/category').each do |node|
            id=node.attr('id').to_i
            parent=node.attr('parentId').to_i
            
			name=node.content.strip

   			skip_cats << id if skip_cats.include?(parent_id)
			next if skip_cats.include?(id)
            
            # next if (($parent ne '' && !defined $cat{$parent})||defined $cat{$id});

			category=Category.find_or_initialize_by(external_id: "netlab_#{id}")
			if category.new_record?
				category.parent=Category.find_by(external_id: "netlab_#{parent_id}") if parent_id
				category.name=name
				category.external_id="netlab_#{id}"
				puts category.name
				category.enabled=true
				category.save!
			end

            # $last=0;
        end

		pricexml.xpath('/xml_catalog/shop/offers/offer').each do |node|
			cat_id=node.xpath('categoryId').first.content
			next if skip_cats.include?(cat_id.to_i)

			id=node.attr('id')
			uid=node.xpath('uid').first.content
			
			# vendorCode=node.xpath('vendorCode').first.content if node.xpath('vendorCode').first
#			vendorCode|=node.articul.content if node.articul

			# manufacturer=node.xpath('vendor').first.content if node.xpath('vendor').first

			sku="netlab_#{uid}"
			# sku="nova_#{manufacturer}.#{vendorCode}" if supplier == 'nova'

			product=Product.find_or_initialize_by(sku: sku)

			product.name=node.xpath('name').first.content
			puts product.name
			product.categories.clear
			product.categories << Category.find_by(external_id: "netlab_#{cat_id}")
			product.sku=sku

			product.save!

			product.attrs.delete_all
			product.attrs.create(name: 'Модель', value: node.xpath('Model').first.content) if node.xpath('Model').first
			product.attrs.create(name: 'Производитель', value: node.xpath('Vendor').first.content) if node.xpath('Vendor').first
			product.attrs.create(name: 'PN', value: node.xpath('PN').first.content) if node.xpath('PN').first

			variant_sku=sku
			variant_name=product.name

			variant=product.variants.find_or_initialize_by(sku: variant_sku)
			variant.sku=variant_sku
			variant.name=variant_name
			price=node.xpath('price').first.content
			price.gsub!(/,/, '')
			variant.price=price
			variant.enabled=true


			variant.availability='Доставка 2-7 дней' if supplier=='nova'
			if supplier=='camp'
				if node.attr('available') == 'false'
					variant.availability='Нет в наличии'
				else
					variant.availability='Доставка 7 дней'
				end
			end
			variant.availability='Доставка 14 дней' if supplier=='salmo'

			variant.attrs.find_or_initialize_by(name: 'Цвет').update(value: color) if color
			variant.attrs.find_or_initialize_by(name: 'Размер').update(value: size) if size
			variant.touch unless variant.new_record?

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