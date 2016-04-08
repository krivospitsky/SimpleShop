class CallbackController < ApplicationController
  def new
	UserMailer.callback(params[:phone]).deliver
	render plain: "OK"
  end
end
