Shop::Application.configure do
	Dir.glob("#{Rails.root}/app/themes/*/assets/*").each do |dir|
		config.assets.paths << dir
	end
end
