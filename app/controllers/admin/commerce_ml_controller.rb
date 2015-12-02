class Admin::CommerceMlController < ApplicationController
skip_before_filter :verify_authenticity_token

	def exchange
		if params[:mode]=='checkauth'
			#!!! todo: auth
			render plain: "success\ncookie\ndasdasdasda"
		end

		if params[:mode]=='init'
			dir='public/uploads/commerceml'
			FileUtils.mkdir_p(dir) unless File.directory?(dir)
			FileUtils.rm_f(File.join(dir, 'import.xml'))
			FileUtils.rm_f(File.join(dir, 'offers.xml'))
			# FileUtils.rm_rf(dir)
			render plain: "zip=no\nfile_limit=10670080"
		end

		if params[:mode]=='file'
		    name = params[:filename]
    		dir = "public/uploads/commerceml"
    		path = File.join(dir, name)
    		File.open(path, "ab") { |f| f.write(request.raw_post) }
			render plain: "success"
		end

		if params[:mode]=='import'
		    name = params[:filename]
    		ImportCommercemlJob.perform_later name
			render plain: "success"
		end
	end
end
