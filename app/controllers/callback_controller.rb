class CallbackController < ApplicationController
  def new
	UserMailer.callback(params[:phone]).deliver
	render js: 'ok'
  end
end
