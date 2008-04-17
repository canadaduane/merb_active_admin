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
  
    # URL builder methods
  
    def active_admin_url(action, model = @model, kvs = {})
      kvs.delete_if{ |k, v| v.nil? }
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/#{model.to_s.downcase.pluralize}/#{action}" +
      (kvs.empty? ? "" : "?#{Merb::Request.params_to_query_string(kvs)}")
    end

    def active_admin_url_with_id(action, id, model = @model, kvs = {})
      kvs.delete_if{ |k, v| v.nil? }
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/#{model.to_s.downcase.pluralize}/#{action}/#{id}" +
      (kvs.empty? ? "" : "?#{Merb::Request.params_to_query_string(kvs)}")
    end
    
    def active_admin_association_url(association, id, model = @model)
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/#{model.to_s.downcase.pluralize}-to-#{association}/#{id}"
    end
    
    def active_admin_home_url
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}"
    end

    def active_admin_stylesheet_url(resource)
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/stylesheet/#{resource}"
    end

    def active_admin_javascript_url(resource)
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/javascript/#{resource}"
    end

    def active_admin_file_url(resource)
      "/#{Merb::Plugins.config[:merb_active_admin][:base_path]}/public/#{resource}"
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
    
    def humanize(word)
      word.to_s.gsub(/^[a-z]|(\_[a-z])/) { |a| a.upcase.gsub("_", " ") }.gsub(/Id$/, "ID")
    end
  end
end