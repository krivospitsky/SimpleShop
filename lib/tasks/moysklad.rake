# coding: utf-8
namespace :moysklad do
	task :import_photo => :environment do
		Product.all.each do |product|
            if product.images.empty?
            	doc = Nokogiri::HTML(open("https://online.moysklad.ru/exchange/rest/ms/xml/Good/list?filter=externalCode%3D#{product.external_id}",
            		http_basic_authentication: ["admin@mama40", "adminmama"]))
            	doc.xpath('//images/image').each do |img|
            		img_url="https://online.moysklad.ru/app/download/#{img.xpath('uuid').first.content}"
					`wget --no-check-certificate -O tmp/product_image.jpg --post-data="j_username=admin@mama40&j_password=adminmama&returnPath=#{img_url}" https://online.moysklad.ru/doLogin`
					sleep 2
            		image=product.images.new          
            		File.open('tmp/product_image.jpg') do |f|
							image.image = f
					end
            		image.save
            	end
            end
        end
	end
end