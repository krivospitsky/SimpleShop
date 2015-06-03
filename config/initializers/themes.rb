Shop::Application.configure do
	Dir.glob("#{Rails.root}/app/themes/#{Settings.theme}/assets/*").each do |dir|
		config.assets.paths << dir
	end
end
