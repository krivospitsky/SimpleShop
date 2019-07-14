# coding: utf-8

#https://oauth.vk.com/authorize?client_id=5922415&display=page&redirect_uri=https%3A//oauth.vk.com/blank.html&scope=photos,groups,market,offline&response_type=token&v=5.62&state=123456
#https://oauth.vk.com/authorize?client_id=3682744&v=5.7&scope=photos,groups,offline&redirect_uri=http://oauth.vk.com/blank.html&display=page&response_type=token
#f721071b64021c8e709c6d1e46cea86cb4e74feec51116a0872cce8cec06993c2ba83e09c29256e83549e

require 'action_view'
require 'uri'

$vk
$vk_cat_id

namespace :cleanup do
	task :vk  => :environment do
		$vk = VkontakteApi::Client.new(Settings.vk_access_token)
		if (Settings.theme == 'mama40' || Rails.env.development?)
			$vk.photos.getAlbums.each do |album|
				puts album.title
				puts album.aid
				if album.aid && Category.find_by(vk_id2: album.aid)
					puts 'обрабатываем альбом'
					photos=$vk.photos.get(album_id: album.aid)
					photos.each do |photo|
						if !Product.find_by(vk_id2: photo.pid)
							puts "Фото с id #{photo.pid} не найдено, удаляем"
							# puts photo.inspect
							$vk.photos.delete(photo_id: photo.pid)
							sleep(1);
						else
							puts "Фото с id #{photo.pid} найдено"
						end
					end
				else
					puts 'альбом не найден'
				end
			end
		end
	end
end

namespace :export do

	task :vk => :environment do
		include ActionView::Helpers::SanitizeHelper
		include ActionView::Helpers::AssetUrlHelper

		$vk = VkontakteApi::Client.new(Settings.vk_access_token)
		
		if Rails.env.development?	
			cats=[{cats: [1669, 1672], name: 'рюкзаки и хипситы'}, 1870]		
			$vk_cat_id=1
		end

		case Settings.theme
			when 'sling'
				cats=[1, 7, 13, 28, 17, 20]									
			when 'shop4x4'
				$vk_cat_id=404
				cats=[331, 2253, 395, 423, 426, 433, 445, 448, 477, 478, 488, 504, 505, 516, 538, 546, 547, 553, 554, 564, 566,      254, 270, 293, 294, 295, 566, 2341, 2346, 2349, 2647, 3030, 3031, 3032, 3033, 301]
			when 'mama40'
				$vk_cat_id=1
				cats=[14, 17, 18, {cats: [55, 13], name: "Прокладки и трусики послеродовые"}, 31, 37, 36, 35, 30, 29, 28, 27, {cats: [24, 57], name: "Шорты и юбки"}, {cats: [46, 48], name: "Слинг-рюкзаки и май-слинги"}, 40, 53, 45, 47, 42, {cats: [38, 26], name: "Брюки, комбинезоны и костюмы"}, {cats: [43, 44], name: "Слинги-шарфы"}, {cats: [6, 8, 9, 10], name: "Детские товары"}, {cats: [20, 21, 22], name: "Подгузники, пеленки и трусики GlorYes!"}]
		end 

		cats.each do |cat_item|
			if cat_item.instance_of? Hash				
				check_and_create_cat(cat_item[:cats][0], cat_item[:name])
				cat_vk_id=Category.find(cat_item[:cats][0]).vk_id
				cat_vk_id2=Category.find(cat_item[:cats][0]).vk_id2
				cat_item[:cats].each do |cat_id|
					proc_cat(cat_id, cat_vk_id, cat_vk_id2)
				end
			else
				check_and_create_cat(cat_item)
				proc_cat(cat_item)
			end
		end		
	end

	def try_n_times(n)
		counter=0
		loop do 
			begin
				yield
				return 0
			rescue Exception => e  
				puts "API error #{e.error_code} !!!"
				# puts e.to_s
				sleep(15)
				counter+=1
				return e.error_code if counter==n
			end
		end
	end

	def proc_cat(cat_id, album=nil, user_album=nil)	
		cat=Category.find(cat_id)
		album=cat.vk_id unless album
		user_album=cat.vk_id2 unless user_album
		Product.in_categories(cat.all_sub_cats).each do |prod|
			name=prod.name
			if (name.length > 100)
				name=prod.name[0, 95]+'...'
				name=name.encode( "windows-1251")
			end

			if !prod.vk_id
				if prod.enabled					
					next if prod.images.empty?
					next if prod.description.length<10

					puts prod.id

					# создать новый товар
					try_n_times(5) do
						img_path=prod.images.present? ? prod.images.first.image.vk.path : asset_path("product_list_no_photo_#{Settings.theme}.png")
						upload_url=$vk.photos.getMarketUploadServer(group_id: Settings.vk_group_id, main_photo: 1).upload_url
						sleep(1.0)
						upload=VkontakteApi.upload(url: upload_url, photo: [img_path, 'image/jpeg'])
						sleep(1.0)
						photo=$vk.photos.saveMarketPhoto(group_id: Settings.vk_group_id, photo: upload[:photo], server: upload[:server], hash: upload[:hash], crop_data: upload[:crop_data], crop_hash: upload[:crop_hash])
						sleep(1.0)

						res=$vk.market.add(owner_id: "-#{Settings.vk_group_id}", name: name, description: strip_tags(prod.description), category_id: $vk_cat_id, price: prod.variants.first.price, main_photo_id: photo[:response][0][:id], deleted: prod.enabled ? 0 : 1)
						sleep(1.0)
						prod.vk_id=res[:market_item_id]
						prod.save
						$vk.market.addToAlbum(owner_id: "-#{Settings.vk_group_id}", item_id: prod.vk_id, album_ids: album)
						sleep(1.0)
					end
				end
			else
				if prod.enabled
					# обновить
					res=try_n_times(5) do
						vk_prod=$vk.market.getById(item_ids: "-#{Settings.vk_group_id}_#{prod.vk_id}", extended: 1)
						sleep(1.0)
						if vk_prod[1]
							$vk.market.edit(item_id: prod.vk_id, owner_id: "-#{Settings.vk_group_id}", name: name, description: strip_tags(prod.description), category_id: $vk_cat_id, price: prod.variants.first.price, main_photo_id: vk_prod[:response][:items][0][:photos][0][:id], deleted: prod.enabled ? 0 : 1)
						else
							# vk не нашел товара, удалить
							$vk.market.delete(item_id: prod.vk_id, owner_id: "-#{Settings.vk_group_id}")
							prod.vk_id=nil
							prod.save
						end
						sleep(1.0)						
					end	
					puts res
					# if res == 1111
					# 	puts 'не поулчилось отредактировать, наверное уже удалено в VK'
					# 	prod.vk_id=nil
					# 	prod.save						
					# end
		
				else
					# товар есть в VK но нет в магазини - удалить из VK
					try_n_times(5) do
						$vk.market.delete(item_id: prod.vk_id, owner_id: "-#{Settings.vk_group_id}")
						sleep(1.0)						
						prod.vk_id=nil
						prod.save
					end		
				end
			end


			if (Settings.theme == 'mama40' || Rails.env.development?)
				if !prod.vk_id2 
					if prod.enabled					
						# создаем новую фоту
						next if prod.images.empty?

						try_n_times(5) do
							img_path=prod.images.present? ? prod.images.first.image.vk.path : asset_path("product_list_no_photo_#{Settings.theme}.png")
							upload_url=$vk.photos.getUploadServer(album_id: user_album).upload_url
							sleep(1.0)
							upload=VkontakteApi.upload(url: upload_url, photo: [img_path, 'image/jpeg'])
							sleep(1.0)
							caption="#{prod.name}\n#{prod.variants.first.price} руб.\n#{strip_tags(prod.description)}"
							photo=$vk.photos.save(album_id: user_album, photos_list: upload[:photos_list], server: upload[:server], hash: upload[:hash], caption: caption)
							sleep(1.0)
							puts photo
							prod.vk_id2=photo[:response][0][pid]
							prod.save
							puts  prod.vk_id2
						end
					end
				else
					# редактируем или удаляем
					if prod.enabled
						res=try_n_times(5) do
							caption="#{prod.name}\n#{prod.variants.first.price} руб.\n#{strip_tags(prod.description)}"
							$vk.photos.edit(photo_id: prod.vk_id2, caption: caption)
							sleep(1.0)
						end
						# if res == 1111
						# 	puts 'не поулчилось отредактировать, наверное уже удалено в VK'
						# 	prod.vk_id2=nil
						# 	prod.save						
						# end
					else
						try_n_times(5) do
							$vk.photos.delete(photo_id: prod.vk_id2)
							prod.vk_id2=nil
							prod.save
							sleep(1.0)
						end
					end
				end
			end
		end
	end


	def check_and_create_cat(cat_id, cat_name=nil)
		cat=Category.find(cat_id)
		cat_name=cat.name unless cat_name
		if !cat.vk_id
			res=$vk.market.addAlbum(owner_id: "-#{Settings.vk_group_id}", title: cat_name)
			cat.vk_id=res[:market_album_id]
			cat.save
			sleep(1.0)
		end
		if !cat.vk_id2 && (Settings.theme == 'mama40' || Rails.env.development?)
			res=$vk.photos.createAlbum(title: cat_name)
			cat.vk_id2=res[:aid]
			cat.save
			sleep(1.0)
		end
	end
end