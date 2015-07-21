class Admin::SettingsController < Admin::BaseController
    actions [:edit]
    
    @@settings_list=[   {title: 'Общее', settings: [:site_title, :site_title_2, :site_url, :owner_phone, :owner_email, :theme, {contacts: :text}, :copy1, :copy2]}, 
                        {title: 'Почта', settings: [:smtp_host, :smtp_port, :smtp_domain, :smtp_user_name, :smtp_password, :smtp_authentication]},
                        {title: 'Аналитика', settings: [{metrika: :text}, :metrika_id, :metrika_cart_goal, :metrika_order_goal, :google_verification, :yandex_verification]},
                        {title: 'Опции', settings: [{disable_categories: :bool}, {disable_filters: :bool}, {disable_cart: :bool}, {hide_count_in_product: :bool}, {enable_variants: :bool}]}]

    def edit
        @settings_list=@@settings_list
    end
    
    def update

        @@settings_list.each do |group|
            group[:settings].each do |set|
                if set.class == Hash
                    if set[set.keys.first] == :text
                        eval "Settings.#{set.keys.first.to_s}=params[:settings][set.keys.first]"
                    elsif set[set.keys.first] == :bool
                        eval "Settings.#{set.keys.first.to_s.to_s}=(params[:settings][set.keys.first] == '1')"
                    end
                else
                    eval "Settings.#{set.to_s}=params[:settings][set]"
                end
            end
        end

        Rails.application.reload_routes!

        redirect_to '/admin/settings/edit'
    end
end
