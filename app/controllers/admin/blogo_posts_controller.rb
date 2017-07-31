class Admin::BlogoPostsController < Admin::BaseController
	actions_except [:clone]
	index_attributes [:title, :published]


    def create
      service = Blogo::CreatePostService.new(Blogo::User.first, permitted_params)

      service.create!

      redirect_to [:admin, controller_name]

    end

    def update
      @post = Blogo::Post.find(params[:id])
      service = Blogo::UpdatePostService.new(@post, permitted_params)
      service.update!
  	  redirect_to [:admin, controller_name]
    end

    def new
    	@url=admin_blogo_posts_path
    	super
    end

    def edit
    	@url="/admin/blogo_posts/#{params[:id]}"
    	super
    end

	private
	
	def class_name
		'Blogo::Post'
	end

	def permitted_params
		params.require(:post).permit(:title, :raw_content, :published, :permalink, :tags_string)
	end
end
