class ImportCommercemlJob < ActiveJob::Base
  queue_as :default

  def perform(name)
	dir = "public/uploads/commerceml"
	path = File.join(dir, name)
	
	doc = File.open(path) { |f| Nokogiri::XML(f) }

	doc.xpath('КоммерческаяИнформация/Классификатор/Группы/Группа').each do |group|
		process_group(group)    			
	end

	doc.xpath('КоммерческаяИнформация/Каталог/Товары/Товар').each do |prod|    			
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

	doc.xpath('КоммерческаяИнформация/ПакетПредложений/Предложения/Предложение').each do |var|    			
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
	        if product.enabled == false
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

	if name =='offers.xml'
		# Variant.where("updated_at < ? and updated_at >= ?", 1.day.ago, 2.week.ago, like_str).update_all(availability: 'Уточнить у менеджера')
		Product.all.each do |prod|
			if prod.variants.enabled.empty?
				puts "товар #{prod.name} недоступен"
				prod.enabled=false
				prod.save
			end
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
