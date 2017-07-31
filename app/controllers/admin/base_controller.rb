require "application_responder"

class Admin::BaseController < ActionController::Base
	layout 'admin'
	self.responder = ApplicationResponder
	respond_to :html
    responders :flash, :http_cache

	before_action :set_title
	before_action :authenticate_admin!


	def index
		@class_obj=class_name.classify.constantize
		if @class_obj.respond_to?('rank')
			@objects = class_name.classify.constantize.rank(:sort_order).page(params[:page]).per(50)
		else
			@objects = class_name.classify.constantize.page(params[:page]).per(50)
		end
    	instance_variable_set("@#{controller_name}", @objects)
    	@index_attributes=get_index_attributes
 		@actions=get_actions
		respond_with @objects
	end


	def new
		@object = class_name.singularize.classify.constantize.new
		puts controller_name.singularize
		instance_variable_set("@#{controller_name.singularize}", @object)
		# form
		# @tabs=@@tabs
		# @object.build_seo unless @object.seo
		respond_with(@object)
    end

	def create
		object = class_name.singularize.classify.constantize.create permitted_params
    	redirect_to [:admin, controller_name]
	end

	def edit  
		@object = class_name.singularize.classify.constantize.find(params[:id])  
		instance_variable_set("@#{controller_name.singularize}", @object)
		# form
		# @tabs=@@tabs
		# @object.build_seo if @object.respond_to?('seo') && !@object.seo
		respond_with(@object)  
	end  

	def update  
		object = class_name.singularize.classify.constantize.find(params[:id])  
		object.update_attributes permitted_params
    	redirect_to [:admin, controller_name]
	end  

	def destroy  
		object = class_name.singularize.classify.constantize.find(params[:id])  
		object.destroy  
    	redirect_to [:admin, controller_name]
	end  


	private

	def class_name
		controller_name		
	end


	def set_title
		@title = t("title.#{controller_name}.#{action_name}")
		if get_actions.include?(:new) && action_name == 'index'
	    	@h1 = @title + '&nbsp;' + (view_context.link_to t('.new', :default => t("helpers.links.new")), eval("new_admin_#{controller_name.singularize}_path"), :class => 'btn btn-primary')
	    else
	    	@h1=@title
	    end
	end

	# def self.index_attributes
	# 	@index_attributes
	# end

	protected

 	def self.index_attributes(index_attributes)
		@index_attributes=index_attributes		
	end

	def self.get_index_attributes
		@index_attributes
	end
	def get_index_attributes
		self.class.get_index_attributes
	end


	
	def self.actions(actions)
		@actions=actions
	end
	def self.get_actions
		@actions
	end
	def get_actions
		self.class.get_actions
	end


	def self.actions_except(actions_except)
		@actions=[:index, :show, :edit, :new, :delete, :clone]
		@actions.delete(actions_except)
	end

	# def form
	# end

	# @@tabs=Hash.new
	# def tab(name)
	# 	@@tabs[name]=Hash.new
	# 	yield(name)
	# end
	# def input(name, tab)
	# 	@@tabs[tab][name]={type: :input}
	# end
	# def ckeditor(name, tab)
	# 	@@tabs[tab][name]={type: :ckeditor}
	# end
	# def image(name, tab)
	# 	@@tabs[tab][name]={type: :image}
	# end
	# def association(name, tab)
	# 	@@tabs[tab][name]={type: :association}
	# end

	# def subform(name, tab)
	# 	@@tabs[tab][name]={type: :subform}		
	# 	@@tabs[tab][name][:items]=Hash.new
	# 	yield(name)
	# end
	
	# def subform_input(name, tab, subform)
	# 	@@tabs[tab][subform][:items][name]={type: :input}
	# end

	# def seo
	# 	tab :seo do |t|
	# 		subform :seo, t do |s|
	# 			subform_input :title, t, s
	# 			subform_input :keywords, t, s
	# 			subform_input :description, t, s
	# 		end
	# 	end
	# end
end
