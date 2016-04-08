class CallbackController < ApplicationController
  def new
	UserMailer.callback(params[:phone]).deliver
	render js: '1'
  end
end
