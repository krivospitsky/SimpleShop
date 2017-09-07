# coding: utf-8

require 'json'

namespace :moysklad do
	task :import_photos => :environment do
		# start=0
		href="https://online.moysklad.ru/api/remap/1.1/entity/product?limit=100"
		loop do 
			puts href
	    	
	    	# doc = Nokogiri::XML(open("https://online.moysklad.ru/exchange/rest/ms/xml/Good/list?start=#{start}&count=1000",
	    	# 	http_basic_authentication: [Settings.ms_login, Settings.ms_password]))
			json = JSON.load(open(href, http_basic_authentication: [Settings.ms_login, Settings.ms_password]))

	        json['rows'].each do |good|
	        	product=Product.find_by(external_id: good['externalCode'])
	            if product && product.images.empty?
	            	if good['image'] && img_url=good['image']['meta']['href']
						puts img_url
						image=product.images.new
						`wget --no-check-certificate --http-user=#{Settings.ms_login} --http-password=#{Settings.ms_password} -O tmp/product_image.jpg #{img_url}`
						sleep 2
            			File.open('tmp/product_image.jpg') do |f|
							image.image = f
						end
						image.save
	            	end
	     #        	good.xpath('images/image').each do |img|
	     #        		img_url="https://online.moysklad.ru/app/download/#{img.xpath('uuid').first.content}"
						# `wget --no-check-certificate -O tmp/product_image.jpg --post-data="j_username=#{Settings.ms_login}&j_password=#{Settings.ms_password}&returnPath=#{img_url}" https://online.moysklad.ru/doLogin`
						# sleep 2
	     #        		image=product.images.new          
	     #        		File.open('tmp/product_image.jpg') do |f|
						# 		image.image = f
						# end
	     #        		image.save
	     #        	end
	            end
	        end
	        # start+=100
	        break unless href=json['meta']['nextHref']
	    end 
	end
	task :import_users => :environment do
    	doc = Nokogiri::XML(open("https://online.moysklad.ru/exchange/rest/ms/xml/Company/list",
    		http_basic_authentication: [Settings.ms_login, Settings.ms_password]))
        doc.xpath('/collection/company').each do |user|
        	card=user.attr('discountCardNumber')
        	if card && card!=''
	        	u=User.find_or_initialize_by(card_number: card)
	        	u.name=user.attr('name')
	        	u.discount=user.attr('autoDiscount')
	        	u.email="#{card}@moysklad.ru"
	        	puts u.email
	        	u.password=Devise.friendly_token[0,20]
				# u.skip_confirmation!
				u.save!
			end
        end
	end
end