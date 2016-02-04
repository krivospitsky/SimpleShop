class Admin::MoscanellaController < ApplicationController
	layout 'admin'
	def new
	end

	def import
		file_data = params[:upload][:xls]
		xls=Roo::Excel.new(file_data.path)
		xls.default_sheet = xls.sheets.first 
		(2..xls.last_row).each do |line|
			sku=xls.cell(line,'A')
			price=xls.cell(line,'C')
			count=xls.cell(line,'E')
			if variant=Variant.find_by(sku: sku)
				variant.price=price*1.5
				if count.to_i>3 || count == '>50'
					variant.availability='Доставка 2-3 дня'
					variant.enabled=true
					variant.product.enabled=true
				else
					variant.availability='Недоступно'
					variant.enabled=false
				end
				variant.touch unless variant.new_record?
				variant.product.save
				variant.save
			end
		end

		Product.where('sku SIMILAR TO "expertfisher_%"').all.each do |prod|
			if prod.variants.enabled.empty?
				prod.enabled=false
				prod.save
			end
		end

		redirect_to '/admin/moscanella/new'
	end
end
