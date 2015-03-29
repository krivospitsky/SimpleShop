class ProductsController < ApplicationController
  responders :flash, :http_cache

  def search
    @text=params[:text]
    @products=Product.search(params[:text]).page(params[:page])
    @title="Результаты поиска"
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])
    @title=@product.title
    @linked=@product.linked
    @cart_item = @current_cart.cart_items.new(product_id: @product.id, quantity:1)
    
    @category = Category.find(params[:category_id])

    @breadcrumbs=[]
    @breadcrumbs << @product
    if params[:category_id]
      tmp=Category.find(params[:category_id])
      while tmp do 
        @breadcrumbs << tmp
        tmp=tmp.parent
      end
      @breadcrumbs=@breadcrumbs.reverse
    end

  end

  def index
    @products=[]
    if params[:category_id]
      @category = Category.find(params[:category_id])
      if @category.parent || @category.products.count>0
        @products = Kaminari.paginate_array(@category.products_in_all_sub_cats).page(params[:page])
      end
      @title = @category.name

      @breadcrumbs=[]
      tmp=@category
      while tmp do 
        @breadcrumbs << tmp
        tmp=tmp.parent
      end
      @breadcrumbs=@breadcrumbs.reverse

    else
      @products=Product.enabled.page(params[:page])
    end

    unless Settings::disable_filters
      @filters=Hash.new
      @products.each do |prod|
        prod.attr.keys.each do |attr|
          @filters[attr]=[] unless @filters[attr]
          @filters[attr] << prod.attr[attr] unless @filters[attr].include?(prod.attr[attr])
        end
      end

      @filters.keys.each do |filter|
        @filters.delete(filter) if @filters[filter].size<2
      end
    end

  end

end
