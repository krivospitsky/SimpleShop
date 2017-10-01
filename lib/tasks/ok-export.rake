# coding: utf-8

#https://connect.ok.ru/oauth/authorize?client_id=1248238080&scope=VALUABLE_ACCESS,LONG_ACCESS_TOKEN,PHOTO_CONTENT,GROUP_CONTENT,MESSAGING&response_type=code&redirect_uri=http://localhost
#https://api.ok.ru/oauth/token.do?code=1U984vxoi4bJvPe1l8afCZKEz5uvnowMQgRDIVuvMZSfRvuZn7NbNPrMVq6mxS2FPIziVrDgAzi5mAkLxj8av3uMKEVr5OE0sZ47mAxpRsAu70u1KN7I4ty82MJQW05otIkRjZFl0vVoUpYrcJkePwltv8avlBpA4fZruYxvtBwRlQf&client_id=1248238080&client_secret=6B2752F47F37F56084CD58A1&redirect_uri=http://localhost&grant_type=authorization_code

require 'action_view'
require 'uri'
require 'rest_client'

namespace :export do
	task :ok => :environment do
		include ActionView::Helpers::SanitizeHelper
		include ActionView::Helpers::AssetUrlHelper
		include ActionView::Helpers::TextHelper
		include ActionView::Helpers::UrlHelper	

		# $ok = VkontakteApi::Client.new(Settings.ok_access_token)

		SchoolFriend.application_id = Settings.ok_application_id
		SchoolFriend.application_key = Settings.ok_application_key
		SchoolFriend.secret_key = Settings.ok_secret_key
		SchoolFriend.api_server = 'http://api.ok.ru'

		$ok = SchoolFriend.session(:access_token => Settings.ok_access_token, session_secret_key: Settings.ok_session_secret_key, refresh_token: 'fake')

		
		if Rails.env.development?	
			cats=[1870, {cats: [1669, 1672], name: 'рюкзаки и хипситы'}]		
		elsif Settings.theme == 'mama40'
			cats=[14, 17, 18, {cats: [55, 13], name: "Прокладки и трусики послеродовые"}, 31, 37, 36, 35, 30, 29, 28, 27, {cats: [24, 57], name: "Шорты и юбки"}, {cats: [46, 48], name: "Слинг-рюкзаки и май-слинги"}, 40, 53, 45, 47, 42, {cats: [38, 26], name: "Брюки, комбинезоны и костюмы"}, {cats: [43, 44], name: "Слинги-шарфы"}, {cats: [6, 8, 9, 10], name: "Детские товары"}, {cats: [20, 21, 22], name: "Подгузники, пеленки и трусики GlorYes!"}]
		elsif Settings.theme == 'sling'
			cats=[1, 7, 13, 28, 17, 20]						
		end

		cats.each do |cat_item|
			if cat_item.instance_of? Hash				
				ok_check_and_create_cat(cat_item[:cats][0], cat_item[:name])
				cat_ok_id=Category.find(cat_item[:cats][0]).ok_id
				cat_item[:cats].each do |cat_id|
					ok_proc_cat(cat_id, cat_ok_id)
				end
			else
				ok_check_and_create_cat(cat_item)
				ok_proc_cat(cat_item)
			end
		end		
	end

def ok_proc_cat(cat_id, album=nil)	
	cat=Category.find(cat_id)
	album=cat.ok_id unless album
	Product.in_categories(cat.all_sub_cats).each do |prod|
		puts prod.name
		caption=truncate("#{prod.name}\n#{prod.variants.first.price} руб.\n#{Settings.site_url}/catalog/product/#{prod.id}", length: 254)
		if !prod.ok_id 
			if prod.enabled					
				# создаем новую фоту
				next if prod.images.empty?
				retr_count =1
				last_retr=false
				loop do  
					break if last_retr
					begin
						img_path=prod.images.present? ? prod.images.first.image.vk.path : asset_path("product_list_no_photo_#{Settings.theme}.png")
						puts img_path
						resp=$ok.photos_v2.get_upload_url(aid: album, gid: Settings.ok_group_id)
						puts resp
						upload_url=resp['upload_url']
						sleep(0.8)
						puts "upload_url - " + upload_url
						response = RestClient.post(upload_url,  :pic1 => File.new(img_path))
						photos= JSON.parse(response)['photos']
						photo_id=photos.keys[0]
						token=photos[photo_id]['token']
						res=$ok.photos_v2.commit(photo_id: photo_id, token: token, comment: caption)
						pid=res['photos'][0]['assigned_photo_id']
						sleep(0.8)

						prod.ok_id=pid
						prod.save

						# $ok.discussions.add_discussion_comment(entityType: 'GROUP_PHOTO', entityId: pid, comment: prod.description, as_admin: true, frmt: 'HTML')
						# puts "comment added"
						# sleep(0.8)
						break
					rescue Exception => e  
						puts "API error!!!"
						puts e.message
						sleep(10)
						retr_count++
						last_retr=true if (retr_count>5)
					end
				end
			end
		else
			# редактируем или удаляем
			if prod.enabled
				# loop do  
				# 	begin
						# ok_prod=$ok.photo.getById(photos: prod.ok_id)
						# sleep(0.8)
						$ok.photos.edit_photo(photo_id: prod.ok_id, gid: Settings.ok_group_id, description: caption)
						puts "edited"
						sleep(0.8)

						# if ($ok.discussions.get_discussion_comments_count(entityType: 'GROUP_PHOTO', entityId: prod.ok_id)['commentsCount'].to_i == 0)
						# 	sleep(0.8)
						# 	res=$ok.discussions.add_discussion_comment(entityType: 'GROUP_PHOTO', entityId: prod.ok_id, comment: prod.description, as_admin: true, frmt: 'HTML')								
						# 	puts res
						# 	puts "comment added"
						# end
						# sleep(0.8)
					# 	break
					# rescue Exception => e  
					# 	puts "API error!!!"
					#   puts e.message
					# 	sleep(10)
					# end
				# end
			else
				retr_count =1
				last_retr=false

				loop do  
					break if last_retr					
					begin
						$ok.photos.delete_photo(photo_id: prod.ok_id, gid: Settings.ok_group_id)
						prod.ok_id=nil
						prod.save
						puts "deleted"
						sleep(0.8)
						break
					rescue Exception => e  
						puts "API error!!!"
						puts e.message
						sleep(10)
						retr_count++
						last_retr=true if (retr_count>5)
					end
				end
			end
		end
	end
end

def ok_check_and_create_cat(cat_id, cat_name=nil)
	cat=Category.find(cat_id)
	cat_name=cat.name unless cat_name
	if !cat.ok_id && (Settings.theme == 'mama40' || Rails.env.development?)
		res=$ok.photos.create_album(title: cat_name, gid: Settings.ok_group_id)
		cat.ok_id=res
		cat.save
		sleep(0.8)
	end
end

end