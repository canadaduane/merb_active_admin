# Note: This file is read in by active_admin.rb and several of the :symbols are replaced
#       with meaningful Ruby classes and values.

class :controller_class < Base
  before :set_model_class
  
  def list(page = 1, per_page = 15)
    @paginated = @model.paginate(page.to_i, per_page.to_i)
    @objects = @paginated.all
    active_admin_render(:list)
  end
  
  def list_data(page = 1)
    per_page, sort_by, order = flexigrid_params
    @paginated = @model.send(order, sort_by).paginate(page.to_i, per_page.to_i)
    @objects = @paginated.all
    active_admin_render(:list_data, "json", false)
  end
  
  def list_association(id, association, page = 1)
    per_page, sort_by, order = flexigrid_params
    if object = @model[id]
      query = object.send(association)
      @paginated = query.send(order, "#{association}__#{sort_by}".to_sym).paginate(page.to_i, per_page.to_i)
      @objects = @paginated.all
      @model = @model.association_reflection(association.to_sym)[:class_name].constantize
      active_admin_render(:list_data, "json", false)
    else
      @objects = []
      active_admin_render(:list_data, "json", false)
    end
  end
  
  def show(id)
    @object = @model[id]
    raise NotFound, "#{@model} #{id} not found" if @object.nil?
    active_admin_render(:show)
  end
  
  def new
    active_admin_render(:new)
  end
  
  def create(object)
    @model.create(object)
    redirect active_admin_url(:list)
  end

  def edit(id)
    @object = @model[id]
    raise NotFound, "#{@model} #{id} not found" if @object.nil?
    active_admin_render(:edit)
  end

  def update(id, object)
    @model[id].update(object)
    redirect active_admin_url(:list)
  end

  def destroy(ids)
    ids.split(",").each{ |id| puts "DESTROY ID: #{id.inspect}"; @model[id].destroy }
    self.content_type = :json
    %([message: "ok"])
  end
  
  protected
  
  def set_model_class
    @model = :model_class
  end
  
  def flexigrid_params
    per_page = params[:per_page] || params[:rp] || 15
    sort_by = (params[:sortname] || "id").to_sym
    order = params[:sortorder] == "asc" ? :order : :reverse_order
    [per_page, sort_by, order]
  end
end
