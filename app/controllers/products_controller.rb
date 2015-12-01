class ProductsController < ApplicationController
  responders :flash, :http_cache

  def search
    @text=params[:text]
    @products=Product.search(params[:text]).page(params[:page])
    @title=get_seo_title(nil)
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])
    set_seo_variables(@product)
    @linked=@product.linked
    @cart_item = @current_cart.cart_items.new(product_id: @product.id, quantity:1)
    
    @category = Category.find(params[:category_id]) if params[:category_id]

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
      @sort_order=params[:sort_order] || 'default'
      case @sort_order
        when 'default'
          sort_key=:sort_order
          sort_dir=:asc
        when 'name'
          sort_key=:name
          sort_dir=:asc
        when 'price_min'
          sort_key=:min_price
          sort_dir=:asc
        when 'price_max'
          sort_key=:max_price
          sort_dir=:desc
      end
        
      @category = Category.find(params[:category_id])
      # if @category.parent || @category.products.count>0
      @products = Product.in_categories(@category.all_sub_cats).enabled
      # end
      set_seo_variables(@category)


      @breadcrumbs=[]
      tmp=@category
      while tmp do 
        @breadcrumbs << tmp
        tmp=tmp.parent
      end
      @breadcrumbs=@breadcrumbs.reverse
    else
      @products=Product.enabled
    end

    unless Settings::disable_filters
      #генерация фильтров
      @filters=Hash.new
      @products.enabled.each do |prod|
        prod.attrs.each do |attr|
          @filters[attr.name]=[] unless @filters[attr.name]
          @filters[attr.name] << attr.value unless @filters[attr.name].include?(attr.value)
        end

        prod.variants.enabled.each do |var|
          var.attrs.each do |attr|
            @filters[attr.name]=[] unless @filters[attr.name]
            @filters[attr.name] << attr.value unless @filters[attr.name].include?(attr.value)
          end          
        end
      end
      @filters.keys.each do |filter|
        @filters.delete(filter) if @filters[filter].size<2
      end

      #фильтрация
      filter=params[:filter]
      @current_filters=Hash.new 
      if filter
        filter.keys.each do |param_name|
          if param_name == 'min-price'
            if filter['min-price'] && filter['min-price'].to_i >0
              @products=@products.where('min_price>=?', filter['min-price'])
              @min_price=filter['min-price'].to_i
            end
          elsif param_name == 'max-price'
            if filter['max-price'] && filter['max-price'].to_i >0
              @products=@products.where('max_price<=?', filter['max-price'])
              @max_price=filter['max-price'].to_i
            end
          else
            # @products=@products.joins(:attrs).joins(variants:{:attrs}).where()
            @products=@products.joins(:attrs).joins(:variant_attrs).where('(attrs.name=? and attrs.value in (?)) or (variant_attrs.name=? and variant_attrs.value in (?))', param_name, filter[param_name], param_name, filter[param_name])
            @current_filters[param_name] = filter[param_name]            
          end
        end        
      end
      @products=Product.where('id in (?)', @products.pluck(:id)) 
    end

    @min_price||=@products.pluck(:min_price).min
    @max_price||=@products.pluck(:max_price).max
    @products=@products.order(sort_key => sort_dir).page(params[:page])
  end
end
