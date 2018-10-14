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
    @product = Product.where(id: params[:id]).first
    @product = Product.where(sku: params[:id]).first unless @product
    raise ActiveRecord::RecordNotFound  unless @product

    set_seo_variables(@product)
    @linked=@product.linked
    @cart_item = @current_cart.cart_items.new(product_id: @product.id, quantity:1)
    
    @category = Category.find(params[:category_id]) if params[:category_id]

    @breadcrumbs=[]
    @breadcrumbs << @product

    cat=params[:category_id] ? Category.find(params[:category_id]) : (@product.categories.empty? ? nil : @product.categories.first)

    if cat
      while cat do 
        @breadcrumbs << cat
        cat=cat.parent
      end
      @breadcrumbs=@breadcrumbs.reverse
    end

  end


  def index
    @products=[]
    @sort_order=params[:sort_order] || 'date'
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
      when 'date'
        sort_key=:returned_at
        sort_dir=:desc
    end
    if params[:category_id]
        
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
    elsif params[:discounted]
      @products = Product.discounted
    else
      @products=Product.enabled
    end

    unless Settings::disable_filters || params[:category_id] == '23'
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

            if attr.value.match(/(\d+)\-(\d+)/) #48-50
              @filters[attr.name] << Regexp.last_match[1] unless @filters[attr.name].include?(Regexp.last_match[1])
              @filters[attr.name] << Regexp.last_match[2] unless @filters[attr.name].include?(Regexp.last_match[2])
            else
              @filters[attr.name] << attr.value unless @filters[attr.name].include?(attr.value)
            end
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

            # @products=@products.joins(:attrs).joins(:variant_attrs).where('(attrs.name=? and attrs.value in (?)) or (variant_attrs.name=? and variant_attrs.value in (?))', param_name, filter[param_name], param_name, filter[param_name])
            regex='%('+filter[param_name].map{|x| "-#{x}"}.join("|")+'|'+filter[param_name].map{|x| "#{x}-"}.join("|")+')%'
            # raise
            @products=@products.joins('LEFT OUTER JOIN "attrs" ON "attrs"."product_id" = "products"."id"').joins('LEFT OUTER JOIN "variants" ON "variants"."product_id" = "products"."id" AND "variants"."enabled" = \'t\'').joins('LEFT OUTER JOIN "variant_attrs" ON "variant_attrs"."variant_id" = "variants"."id"').where('(attrs.name=? and attrs.value in (?)) or (variant_attrs.name=? and (variant_attrs.value in (?) or variant_attrs.value similar to ?))', param_name, filter[param_name], param_name, filter[param_name], regex).uniq

            @current_filters[param_name] = filter[param_name]            
          end
        end        
      end
      # @products=Product.where('id in (?)', @products.pluck(:id)) 
    end

    @min_price||=@products.pluck(:min_price).min
    @max_price||=@products.pluck(:max_price).max
    @products=@products.order(sort_key => sort_dir).page(params[:page])
  end
end
