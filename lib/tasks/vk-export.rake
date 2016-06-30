# coding: utf-8

require 'action_view'
require 'uri'

$vk

namespace :vk do
	task :export => :environment do
		include ActionView::Helpers::SanitizeHelper
		include ActionView::Helpers::AssetUrlHelper

		$vk = VkontakteApi::Client.new(Settings.vk_access_token)
	
		if Rails.env == 'production'
			cats=[14, 17, 18, {cats: [55, 13], name: "Прокладки и трусики послеродовые"}, 31, 37, 36, 35, 30, 29, 28, 27, {cats: [24, 57], name: "Шорты и юбки"}, {cats: [46, 48], name: "Слинг-рюкзаки и май-слинги"}, 40, 53, 45, 47, 42, {cats: [38, 26], name: "Брюки, комбинезоны и костюмы"}, {cats: [43б 44], name: "Слинги-шарфы"}]					
		else
			cats=[{cats: [1669, 1672], name: 'рюкзаки и хипситы'}, 1870]		
		end

		cats.each do |cat_item|
			if cat_item.instance_of? Hash				
				check_and_create_cat(cat_item[:cats][0], cat_item[:name])
				cat_vk_id=Category.find(cat_item[:cats][0]).vk_id
				cat_item[:cats].each do |cat_id|
					proc_cat(cat_id, cat_vk_id)
				end
			else
				check_and_create_cat(cat_item)
				proc_cat(cat_item)
			end
		end		
	end
end

def proc_cat(cat_id, album=nil)	
	cat=Category.find(cat_id)
	album=cat.vk_id unless album
	Product.in_categories(cat.all_sub_cats).each do |prod|
		if !prod.vk_id
			if prod.enabled					
				next if prod.images.empty?
				next if prod.description.length<10

				loop do  
					begin
						img_path=prod.images.present? ? prod.images.first.image.vk.path : asset_path("product_list_no_photo_#{Settings.theme}.png")
						upload_url=$vk.photos.getMarketUploadServer(group_id: Settings.vk_group_id, main_photo: 1).upload_url
						sleep(0.4)
						upload=VkontakteApi.upload(url: upload_url, photo: [img_path, 'image/jpeg'])
						sleep(0.4)
						photo=$vk.photos.saveMarketPhoto(group_id: Settings.vk_group_id, photo: upload[:photo], server: upload[:server], hash: upload[:hash], crop_data: upload[:crop_data], crop_hash: upload[:crop_hash])
						sleep(0.4)

						res=$vk.market.add(owner_id: "-#{Settings.vk_group_id}", name: prod.name, description: strip_tags(prod.description), category_id: 1, price: prod.variants.first.price, main_photo_id: photo[0][:pid], deleted: prod.enabled ? 0 : 1)
						sleep(0.4)
						prod.vk_id=res[:market_item_id]
						prod.save
						$vk.market.addToAlbum(owner_id: "-#{Settings.vk_group_id}", item_id: prod.vk_id, album_ids: album)
						sleep(0.4)
						break
					rescue 
						puts "API error!!!"
					end
				end
			end
		else

			# vk.execute(code: "var prod=API.market.getById({\"item_ids\": \"-#{Settings.vk_group_id}_#{prod.vk_id}\", \"extended\": 1});API.market.edit({\"item_id\": \"#{prod.vk_id}\", \"owner_id\": \"-#{Settings.vk_group_id}\", \"name\": \"#{prod.name}\", \"description\": \"#{URI.encode(strip_tags(prod.description))}\",  \"category_id\": 1, \"price\": #{prod.variants.first.price}, \"main_photo_id\": prod.items[0].photos[0].id, \"deleted\": #{prod.enabled ? 0 : 1}});return 1;")
			puts "-#{Settings.vk_group_id}_#{prod.vk_id}"
			loop do  
				begin
					vk_prod=$vk.market.getById(item_ids: "-#{Settings.vk_group_id}_#{prod.vk_id}", extended: 1)
					sleep(0.4)
					$vk.market.edit(item_id: prod.vk_id, owner_id: "-#{Settings.vk_group_id}", name: prod.name, description: strip_tags(prod.description), category_id: 1, price: prod.variants.first.price, main_photo_id: vk_prod[1].photos[0][:pid], deleted: prod.enabled ? 0 : 1)
					sleep(0.4)
					break
				rescue 
					puts "API error!!!"
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
		sleep(0.4)
	end
end