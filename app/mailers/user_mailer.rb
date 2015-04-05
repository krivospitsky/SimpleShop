#coding:utf-8
class UserMailer < ActionMailer::Base
	helper :application

  def delivery_options
    {
      address:              Settings.smtp_host,
      port:                 Settings.smtp_port,
      domain:               Settings.smtp_domain,
      user_name:            Settings.smtp_user_name,
      password:             Settings.smtp_password,
      authentication:       Settings.smtp_authentication,
      enable_starttls_auto: true
    }
  end

  def order_confirmation(order)
    @order=order
    mail(to: order.email, subject:"Подтверждение заказа", from: Settings.owner_email, delivery_method_options: delivery_options)
  end

  def new_order(order)
    @order=order
    if order.email.empty?
    	mail(to: Settings.owner_email, subject:"Новый заказ", from: Settings.owner_email, delivery_method_options: delivery_options)
    else
    	mail(to: Settings.owner_email, subject:"Новый заказ", from: order.email, delivery_method_options: delivery_options)
    end
  end
end
