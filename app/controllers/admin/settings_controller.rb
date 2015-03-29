class Admin::SettingsController < ApplicationController
  layout 'admin'

  def update
    Settings.site_title=params[:settings][:site_title]
    Settings.site_title_2=params[:settings][:site_title_2]
    Settings.site_url=params[:settings][:site_url]
    Settings.owner_phone=params[:settings][:owner_phone]
    Settings.owner_email=params[:settings][:owner_email]
    Settings.metrika=params[:settings][:metrika]
    Settings.theme=params[:settings][:theme]
    Settings.disable_categories=(params[:settings][:disable_categories] == '1')
    Settings.disable_filters=(params[:settings][:disable_filters] == '1')
    Settings.hide_count_in_product=(params[:settings][:hide_count_in_product] == '1')
    Settings.enable_variants=(params[:settings][:enable_variants] == '1')
    redirect_to '/admin/settings/edit'
  end
end
