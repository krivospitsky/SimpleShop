require "application_responder"

class Admin::BaseController < ActionController::Base
	layout 'admin'
	self.responder = ApplicationResponder
	respond_to :html
    responders :flash, :http_cache

	before_action :set_title
#	before_action :authenticate_admin!


	def index
		objects = controller_name.classify.constantize.rank(:sort_order).page(params[:page]).per(50)
    	instance_variable_set("@#{controller_name}", objects)
		respond_with objects
	end


	def new
		object = controller_name.singularize.classify.constantize.new
		instance_variable_set("@#{controller_name.singularize}", object)
		respond_with(object)
    end

	def create
		object = controller_name.singularize.classify.constantize.create permitted_params
    	redirect_to [:admin, controller_name]
	end

	def edit  
		object = controller_name.singularize.classify.constantize.find(params[:id])  
		instance_variable_set("@#{controller_name.singularize}", object)
		respond_with(object)  
	end  

	def update  
		object = controller_name.singularize.classify.constantize.find(params[:id])  
		object.update_attributes permitted_params
    	redirect_to [:admin, controller_name]
	end  

	def destroy  
		object = controller_name.singularize.classify.constantize.find(params[:id])  
		object.destroy  
    	redirect_to [:admin, controller_name]
	end  

	private

	def set_title
		@h1 = @title = t("title.#{controller_name}.#{action_name}")
	end

	protected

end