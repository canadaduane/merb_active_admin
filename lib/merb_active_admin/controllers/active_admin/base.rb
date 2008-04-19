module ActiveAdmin
  class Base < Application
    PSEUDO_PUBLIC_DIR = File.join(ACTIVE_ADMIN_ROOT, "pseudo_public")
    
    # Set the template root for our plugin.  All ActiveAdmin classes inherit from
    # this Base class, so they will all have the same root directory.
    self._template_root = File.join(ACTIVE_ADMIN_ROOT, "views")
    
    before :get_models
     
    def index
      active_admin_render(:index)
    end

  protected

    def active_admin_module
      Merb::Plugins.config[:merb_active_admin][:base_path]
    end
    
    def controller_for_model(model)
      model.to_s.underscore.pluralize
    end
    
    def module_and_controller_for_model(model)
      active_admin_module + "/" + controller_for_model(model)
    end
  
    # URL builder methods
  
    def active_admin_url(action, model = @model, kvs = {})
      kvs.delete_if{ |k, v| v.nil? }
      "/#{module_and_controller_for_model(model)}/#{action}" +
      (kvs.empty? ? "" : "?#{Merb::Request.params_to_query_string(kvs)}")
    end

    def active_admin_url_with_id(action, id, model = @model, kvs = {})
      kvs.delete_if{ |k, v| v.nil? }
      "/#{module_and_controller_for_model(model)}/#{action}/#{id}" +
      (kvs.empty? ? "" : "?#{Merb::Request.params_to_query_string(kvs)}")
    end
    
    def active_admin_association_url(association, id, model = @model)
      "/#{module_and_controller_for_model(model)}-to-#{association}/#{id}"
    end
        
    def active_admin_home_url
      "/#{active_admin_module}"
    end

    def active_admin_stylesheet_url(resource)
      "/#{active_admin_module}/stylesheet/#{resource}"
    end

    def active_admin_javascript_url(resource)
      "/#{active_admin_module}/javascript/#{resource}"
    end

    def active_admin_file_url(resource)
      "/#{active_admin_module}/public/#{resource}"
    end

    # Helper methods
  
    def get_models
      @models = ActiveAdmin.registered_models  
    end
    
    def active_admin_render(action, type = "html", layout = true)
      render nil, :template => "active_admin/#{action}.#{type}",
                  :layout   => (layout ? "active_admin" : nil)
    end

    def active_admin_partial(template, locals = {})
      (@_old_partial_locals ||= []).push @_merb_partial_locals
      @_merb_partial_locals = locals
      template_method, template_location =
        _template_for("_#{template}", "html", "active_admin",
          :template => "active_admin/_#{template}.html")
      sent_template = send(template_method)
      @_merb_partial_locals = @_old_partial_locals.pop
      sent_template
    end
    
    def underscored_to_human_readable(word)
      word.to_s.gsub(/^[a-z]|(\_[a-z])/) { |a| a.upcase.gsub("_", " ") }.gsub(/Id$/, "ID")
    end
    
    def camelized_to_human_readable(word)
      underscored_to_human_readable( word.underscore )
    end
    
    def column_type(model, column)
      model.schema.create_info.first.find{ |c| c[:name] == column.to_sym }[:type]
    end
    
    def column_width(model, column)
      case column_type(model, column)
      when :string  then 100
      when :text    then 160
      when :integer then 35
      else               100
      end
    end
  end
end