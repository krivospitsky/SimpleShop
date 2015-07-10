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
				else
					variant.availability='Нет в наличии'
				end
				variant.save
			end
		end
		redirect_to '/admin/moscanella/new'
	end
end
