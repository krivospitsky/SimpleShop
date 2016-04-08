class CallbackController < ApplicationController
  def new
	UserMailer.callback(params[:phone]).deliver
  end
end
