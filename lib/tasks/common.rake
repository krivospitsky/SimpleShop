# coding: utf-8
namespace :import do
	task :finalize => :environment do
		c=Variant.where("updated_at < ?", 2.month.ago).update_all(availability: 'Недоступно', enabled: false)
		puts "Недоступно #{c}"
		c=Variant.where("updated_at < ? and updated_at >= ?", 2.week.ago, 2.month.ago).update_all(availability: 'Нет на складе')
		puts "Нет на складе #{c}"
		c=Variant.where("updated_at < ? and updated_at >= ?", 1.day.ago, 2.week.ago).update_all(availability: 'Уточнить у менеджера')
		puts "Уточнить у менеджера #{c}"
		# Variant.all.each do |variant|
		# 	if variant.updated_at < 2.month.ago
		# 		puts "вариант #{variant.name} #{variant.sku} недоступен"
		# 		variant.availability='Недоступно'				
		# 		variant.enabled=false
		# 		variant.save
		# 	elsif variant.updated_at < 2.week.ago
		# 		puts "вариант #{variant.name} #{variant.sku} нет на складе"
		# 		variant.availability='Нет на складе'
		# 		variant.save
		# 	elsif variant.updated_at < 1.hour.ago
		# 		puts "вариант #{variant.name} #{variant.sku} уточнить у менеджера"
		# 		variant.availability='Уточнить у менеджера'
		# 		variant.save
		# 	end
		# end
		Product.all.each do |prod|
			if prod.variants.enabled.empty?
				puts "товар #{prod.name} недоступен"
				prod.enabled=false
				prod.save
			end
		end
	end
end