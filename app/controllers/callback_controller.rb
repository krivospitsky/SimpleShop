class CallbackController < ApplicationController
  def new
  	if params[:phone] && params[:phone] !=''
		UserMailer.callback(params[:phone]).deliver
		render plain: "OK"
	else
		render plain: "Не заадан номер телефона"
		# render status: :unprocessable_entity
	end
  end
end
