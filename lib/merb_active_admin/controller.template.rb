# Note: This file is read in by active_admin.rb and the following symbols are replaced
# with meaningful Ruby classes and values:
#   :controller_class - the class of the controller, which is model.to_s.pluralize by default
#   :model_class      - the class of the Sequel model 

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
      query = object.send("#{association}_dataset")
      @paginated = query.send(order, "#{association}__#{sort_by}".to_sym).paginate(page.to_i, per_page.to_i)
      @objects = @paginated.all
      @model = @model.association_reflection(association.to_sym)[:class_name].constantize
      active_admin_render(:list_data, "json", false)
    else
      @objects = []
      active_admin_render(:list_data, "json", false)
    end
  end
  
  def associate(id, association, assoc_ids)
    do_association_method(id, association, assoc_ids, :add)
    %({message: "ok"})
  end

  def disassociate(id, association, assoc_ids)
    do_association_method(id, association, assoc_ids, :remove)
    %({message: "ok"})
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
    ids.split(",").each{ |id| @model[id].destroy }
    self.content_type = :json
    %({message: "ok"})
  end
  
  protected
  
  def set_model_class
    # See comment at beginning of file
    @model = :model_class
  end
  
  def flexigrid_params
    per_page = params[:per_page] || params[:rp] || 15
    sort_by = (params[:sortname] || "id").to_sym
    order = params[:sortorder] == "asc" ? :order : :reverse_order
    [per_page, sort_by, order]
  end
  
  def do_association_method(id, association, assoc_ids, act)
    object = @model[id]
    klass = @model.association_reflection(association.to_sym)[:class_name].constantize
    lookup = case act
      when :add
        :association_add_method_name
      when :remove
        :association_remove_method_name
      end
    method = @model.send(lookup, association)
    assoc_ids.split(",").each do |assoc_id|
      object.send(method, klass[assoc_id])
    end
  end
    
end
