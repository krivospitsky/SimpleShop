class Admin::CommerceMlController < ApplicationController
skip_before_filter :verify_authenticity_token

	def exchange
		if params[:mode]=='checkauth'
			#!!! todo: auth
			render plain: "success\ncookie\ndasdasdasda"
		end

		if params[:mode]=='init'
			dir='tmp/commerceml'
			FileUtils.mkdir_p(dir) unless File.directory?(dir)
			# FileUtils.rm_rf(dir)
			render plain: "zip=no\nfile_limit=10670080"
		end

		if params[:mode]=='file'
		    name = params[:filename]
    		dir = "tmp/commerceml"
    		path = File.join(dir, name)
    		File.open(path, "wb") { |f| f.write(request.raw_post) }
			render plain: "success"
		end

		if params[:mode]=='import'
		    name = params[:filename]
    		dir = "tmp/commerceml"
    		path = File.join(dir, name)
    		
    		doc = File.open(path) { |f| Nokogiri::XML(f) }

    		doc.xpath('КоммерческаяИнформация/Классификатор/Группы/Группа').each do |group|
				process_group(group)    			
    		end

    		doc.xpath('КоммерческаяИнформация/Каталог/Товары/Товар').each do |prod|    			
				product=Product.find_or_initialize_by(external_id: prod.xpath('Ид').first.content)
    			product.sku=prod.xpath('Артикул').first.content
    			product.name=prod.xpath('Наименование').first.content

    			prod.xpath('ЗначенияРеквизитов/ЗначениеРеквизита').each do |rec|    			
    				if rec.xpath('Наименование').first.content == 'Полное наименование'
    					product.description = rec.xpath('Значение').first.content
    				end
    			end

    			product.categories.delete_all
                prod.xpath('Группы/Ид').each do |cat|
                	product.categories << Category.find_by(external_id: cat.content)
                end

                product.enabled=true
                product.save
                if product.images.empty?
                	doc = Nokogiri::HTML(open("https://online.moysklad.ru/exchange/rest/ms/xml/Good/list?filter=externalCode%3D#{product.external_id}",
                		http_basic_authentication: ["admin@mama40", "adminmama"]))
                	doc.xpath('//images/image').each do |img|
                		img_url="https://online.moysklad.ru/app/download/#{img.xpath('uuid').first.content}"
						`wget --no-check-certificate -O tmp/product_image.jpg --post-data="j_username=admin@mama40&j_password=adminmama&returnPath=#{img_url}" https://online.moysklad.ru/doLogin`
                		image=product.images.new          
                		File.open('tmp/product_image.jpg') do |f|
  							image.image = f
						end
                		image.save
                	end
                end
    		end

    		doc.xpath('КоммерческаяИнформация/ПакетПредложений/Предложения/Предложение').each do |var|    			
    			variant=Variant.find_or_initialize_by(external_id: var.xpath('Ид').first.content)
    			variant.product=Product.find_by(external_id: variant.external_id.split('#')[0])
    			var.xpath('Цены/Цена').each do |price|
    				if price.xpath('ИдТипаЦены').first.content == 'cbcf493b-55bc-11d9-848a-00112f43529a'
    					variant.price=price.xpath('ЦенаЗаЕдиницу').first.content
    				end
    			end
    			variant.count=var.xpath('Количество').first.content
    			if variant.count>0
    				variant.availability='В наличии'
    				variant.enabled=true
    			else
    				variant.availability='Нет в наличии'
    				variant.enabled=false
    			end

    			variant.name=variant.product.name    			
    			variant.sku=variant.product.sku
    			variant.attrs.delete_all
    			first_var=true
    			var_exist=false
    			var.xpath('ХарактеристикиТовара/ХарактеристикаТовара').each do |v_attr|
    				if first_var
    					variant.name+=' ('
    				else
    					variant.name+=', '    					
    				end
    				a=variant.attrs.new
    				a.name=v_attr.xpath('Наименование').first.content
    				a.value=v_attr.xpath('Значение').first.content
    				a.save
    				variant.name+= "#{a.name.mb_chars.downcase.to_s} #{a.value}"
    				variant.sku+="_#{a.value}"
    				first_var=false
    				var_exist=true
    			end
				variant.name+=')' if var_exist
    			variant.save    			
    		end
    		
			render plain: "success"
		end
	end

	private

	def process_group(group, parent_gr=nil)
		category=Category.find_or_initialize_by(external_id: group.xpath('Ид').first.content )
		category.name=group.xpath('Наименование').first.content.strip
		puts category.name
		category.parent=parent_gr if parent_gr
		category.enabled=true
		category.save

		group.xpath('Группы/Группа').each do |sub_group|
			process_group(sub_group, category)
		end
	end
end
