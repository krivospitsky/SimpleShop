class Admin::SettingsController < ApplicationController
  layout 'admin'

  def update
    Settings.site_title=params[:settings][:site_title]
    Settings.site_title_2=params[:settings][:site_title_2]
    Settings.site_url=params[:settings][:site_url]
    Settings.owner_phone=params[:settings][:owner_phone]
    Settings.owner_email=params[:settings][:owner_email]
    Settings.theme=params[:settings][:theme]
    Settings.disable_categories=(params[:settings][:disable_categories] == '1')
    Settings.disable_filters=(params[:settings][:disable_filters] == '1')
    Settings.hide_count_in_product=(params[:settings][:hide_count_in_product] == '1')
    Settings.enable_variants=(params[:settings][:enable_variants] == '1')

    Settings.smtp_host=params[:settings][:smtp_host]
    Settings.smtp_port=params[:settings][:smtp_port]
    Settings.smtp_domain=params[:settings][:smtp_domain]
    Settings.smtp_user_name=params[:settings][:smtp_user_name]
    Settings.smtp_password=params[:settings][:smtp_password]
    Settings.smtp_authentication=params[:settings][:smtp_authentication]

    Settings.contacts=params[:settings][:contacts]
    Settings.copy1=params[:settings][:copy1]
    Settings.copy2=params[:settings][:copy2]

    Settings.metrika=params[:settings][:metrika]
    Settings.google_verification=params[:settings][:google_verification]
    Settings.yandex_verification=params[:settings][:yandex_verification]


#    smtp_enable_starttls_auto: true  
    
    Rails.application.reload_routes!
    # Dir.glob("#{Rails.root}/app/themes/#{Settings.theme}/assets/*").each do |dir|
    #   Rails.application.config.assets.paths << dir
    # end


    redirect_to '/admin/settings/edit'
  end
end
