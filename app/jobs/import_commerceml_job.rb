#encoding: utf-8

class ImportCommercemlJob < ActiveJob::Base
  queue_as :default

  def perform(name)
	# return if Settings.theme == 'fish' && name =='import.xml'
	
	dir = "public/uploads/commerceml"
	path = File.join(dir, name)
		
	doc = File.open(path) { |f| Nokogiri::XML(f) }

	ns='xmlns:' if Settings.theme == 'fish'

	puts "#{name} открыт"

	if Settings.theme != 'fish'
		doc.xpath("#{ns}КоммерческаяИнформация/#{ns}Классификатор/#{ns}Группы/#{ns}Группа").each do |group|
			process_group(group)    			
		end
	end

	doc.xpath("#{ns}КоммерческаяИнформация/#{ns}Каталог/#{ns}Товары/#{ns}Товар").each do |prod|    			
		# puts "Товар"

		if Settings.theme == 'fish'
			id=get_xpath_val(prod, "#{ns}Ид")
			variant=Variant.find_by(external_id: id)	
			shtrih=get_xpath_val(prod, "#{ns}Штрихкод")
			variant|=Variant.find_by(sku: shtrih) if shtrih
			sku=get_xpath_val(prod, "#{ns}Артикул")
			variant|=Variant.find_by(sku: sku) if sku

			if variant
				variant.external_id=id
				variant.save
			else
				puts "variant #{shtrih} - #{sku} not found"
			end
			
		else

			product=Product.find_or_initialize_by(external_id: prod.xpath('Ид').first.content.strip)
			product.sku=prod.xpath('Артикул').first.content.strip
			product.name=prod.xpath('Наименование').first.content.strip

			puts product.name

			prod.xpath('ЗначенияРеквизитов/ЗначениеРеквизита').each do |rec|    			
				if rec.xpath('Наименование').first.content == 'Полное наименование'
					product.description = rec.xpath('Значение').first.content.strip.gsub("\n", "<br>\n")
				end
			end

			product.categories.delete_all
	        prod.xpath('Группы/Ид').each do |cat|
	        	product.categories << Category.find_by(external_id: cat.content.strip)
	        end
	        product.save
	    end
	end

	doc.xpath("#{ns}КоммерческаяИнформация/#{ns}ПакетПредложений/#{ns}Предложения/#{ns}Предложение").each do |var|    			
		# puts "предложение"
		if Settings.theme == 'fish'
			variant=Variant.find_by(external_id: var.xpath("#{ns}Ид").first.content.strip)
			if variant
				variant.availability='В наличии'
				variant.enabled=true
				product=variant.product

		        if product.enabled != true
			        puts "enabling  #{product.name}"
		        	product.enabled=true
		        	product.returned_at=Time.now()
		        	product.save
		        end
		        variant.save
		    else
		    	puts "variant #{var.xpath('Ид').first.content.strip} not found"
		    end
		else
			variant=Variant.find_or_initialize_by(external_id: var.xpath('Ид').first.content.strip)
			variant.product=Product.find_by(external_id: variant.external_id.split('#')[0])
			var.xpath('Цены/Цена').each do |price|
				if price.xpath('ИдТипаЦены').first.content.strip == 'cbcf493b-55bc-11d9-848a-00112f43529a'
					variant.price=price.xpath('ЦенаЗаЕдиницу').first.content.strip
				end
			end
			variant.count=var.xpath('Количество').first.content.strip
			if variant.count>0
				variant.availability='В наличии'
				variant.enabled=true
		        product=variant.product
		        # puts "!!! #{product.name} !! #{product.enabled}"
		        if product.enabled != true
			        puts "enabling  #{product.name}"
		        	product.enabled=true
		        	product.returned_at=Time.now()
		        	product.save
		        end

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
				a.name=v_attr.xpath('Наименование').first.content.strip
				a.value=v_attr.xpath('Значение').first.content.strip
				if a.value.match(/\((.+)\)/)
					puts "#{a.value} -> #{Regexp.last_match[1]}"
					a.value=Regexp.last_match[1]
				end
				a.save
				variant.name+= "#{a.name.mb_chars.downcase.to_s} #{a.value}"
				variant.sku+="_#{a.value}"
				first_var=false
				var_exist=true
			end
			variant.name+=')' if var_exist
			puts variant.name
			variant.save    			
		end
	end

	if name =='offers.xml' && Settings.theme != 'fish'
		# Variant.where("updated_at < ? and updated_at >= ?", 1.day.ago, 2.week.ago, like_str).update_all(availability: 'Уточнить у менеджера')
		Product.all.each do |prod|
			if prod.variants.enabled.empty?
				puts "товар #{prod.name} недоступен"
				prod.enabled=false
				prod.save
			end
		end		
		if Settings.theme == 'mama40'
			`rake -f #{Rails.root.join("Rakefile")} moysklad:import_photos`
			`rake -f #{Rails.root.join("Rakefile")} moysklad:import_users`
		end
	end
  end

	private

	def process_group(group, parent_gr=nil)
		category=Category.find_or_initialize_by(external_id: group.xpath('Ид').first.content.strip )
		category.name=group.xpath('Наименование').first.content.strip
		puts category.name
		category.parent=parent_gr if parent_gr
		category.enabled=true if category.new_record?
		category.save

		group.xpath('Группы/Группа').each do |sub_group|
			process_group(sub_group, category)
		end
	end

end


def get_xpath_val(node, xpath)
	res=node.xpath(xpath)
	if res.length
		return res.first.content.strip
	else
		return nil
	end
end