class Admin::SettingsController < Admin::BaseController
    actions [:edit]
    
    @@settings_list=[   {title: 'Общее', settings: [:site_title, :site_title_2, :site_url, :company, :owner_phone, :owner_email, :theme, {contacts: :text}, :copy1, :copy2, :pers_data_url]}, 
                        {title: 'Почта', settings: [:smtp_host, :smtp_port, :smtp_domain, :smtp_user_name, :smtp_password, :smtp_authentication]},
                        {title: 'Фото', settings: [:list_width, :list_height, :show_width, :show_height]},
                        {title: 'МойСклад', settings: [:ms_login, :ms_password]},
                        {title: 'Yandex Kassa', settings: [:kassa_shopId, :kassa_scid, :kassa_form_action]},
                        {title: 'Yandex Кошелек', settings: [:ya_money_receiver]},
                        {title: 'Yandex Market', settings: [{ya_market_store: :bool}, {ya_market_pickup: :bool}, {ya_market_delivery: :bool}, :ya_market_sales_notes]},
                        {title: 'Магазин VK', settings: [:vk_access_token, :vk_group_id]},
                        {title: 'Магазин OK', settings: [:ok_access_token, :ok_session_secret_key, :ok_group_id, :ok_application_id, :ok_application_key, :ok_secret_key]},
                        {title: 'Аналитика', settings: [{metrika: :text}, :metrika_id, :metrika_cart_goal, :metrika_order_goal, :google_verification, :yandex_verification]},
                        {title: 'Опции', settings: [{disable_categories: :bool}, {disable_filters: :bool}, {disable_cart: :bool}, {disable_discount_card: :bool}, {hide_count_in_product: :bool}, {enable_variants: :bool}, {use_blog: :bool}]}]

    def edit
        @settings_list=@@settings_list
    end
    
    def update

        recreate=1 if (Settings[:list_width] != params[:settings][:list_width])||(Settings[:list_height] != params[:settings][:list_height])||(Settings[:show_width] != params[:settings][:show_width])||(Settings[:show_height] != params[:settings][:show_height])
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
        RecreateImagesJob.perform_later if recreate

        redirect_to '/admin/settings/edit'
    end
end
