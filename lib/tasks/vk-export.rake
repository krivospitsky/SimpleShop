# coding: utf-8

require 'action_view'

namespace :vk do
	task :export => :environment do
		# include ActionView::Helpers::SanitizeHelper
		include ActionView::Helpers
		
		vk = VkontakteApi::Client.new(Settings.vk_access_token)
	
		if Rails.env == 'production'
			cats=[31, 37]					
		else
			cats=[1870]		
		end

		cats.each do |cat_id|
			cat=Category.find(cat_id)
			if !cat.vk_id
				res=vk.market.addAlbum(owner_id: "-#{Settings.vk_group_id}", title: cat.name)
				cat.vk_id=res[:market_album_id]
				cat.save
				sleep(1.1)
			end

			Product.in_categories(cat.all_sub_cats).each do |prod|
				if !prod.vk_id
					if prod.enabled					
						img_path=prod.images.present? ? prod.images.first.image.vk.path : image_path("product_list_no_photo_#{Settings.theme}.png")
						upload_url=vk.photos.getMarketUploadServer(group_id: Settings.vk_group_id, main_photo: 1).upload_url
						sleep(1.1)
						upload=VkontakteApi.upload(url: upload_url, photo: [img_path, 'image/jpeg'])
						sleep(1.1)
						photo=vk.photos.saveMarketPhoto(group_id: Settings.vk_group_id, photo: upload[:photo], server: upload[:server], hash: upload[:hash], crop_data: upload[:crop_data], crop_hash: upload[:crop_hash])
						sleep(1.1)

						res=vk.market.add(owner_id: "-#{Settings.vk_group_id}", name: prod.name, description: strip_tags(prod.description), category_id: 1, price: prod.variants.first.price, main_photo_id: photo[0][:pid], deleted: prod.enabled ? 0 : 1)
						sleep(1.1)
						prod.vk_id=res[:market_item_id]
						prod.save
						vk.market.addToAlbum(owner_id: "-#{Settings.vk_group_id}", item_id: prod.vk_id, album_ids: cat.vk_id)
						sleep(1.1)
					end
				else
					vk_prod=vk.market.getById(item_ids: "-#{Settings.vk_group_id}_#{prod.vk_id}", extended: 1)
					sleep(1.1)
					vk.market.edit(item_id: prod.vk_id, owner_id: "-#{Settings.vk_group_id}", name: prod.name, description: strip_tags(prod.description), category_id: 1, price: prod.variants.first.price, main_photo_id: vk_prod[1].photos[0][:pid], deleted: prod.enabled ? 0 : 1)
					sleep(1.1)
				end
			end
		end

		
	end
end