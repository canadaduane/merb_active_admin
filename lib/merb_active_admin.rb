# make sure we're running inside Merb
if defined?(Merb::Plugins)
  def Merb.active_admin_default_header_models
    hm = Merb::Plugins.config[:merb_active_admin][:header_models]
    if hm.empty?
      # Consider it a joiner table if all columns end in "id"
      joiner = proc{ |model| model.columns.all?{ |c| c.to_s =~ /id$/ } }
      defaults = ActiveAdmin.registered_models.reject{ |m| joiner[m] }
      # Use the first 5 non-joiner tables as defaults
      hm.replace defaults[0..4]
    end
  end
  
  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_active_admin] = {
    
    # This is the public-facing base path of ActiveAdmin, e.g. /active_admin/model/list
    :base_path => "active_admin",
    
    # This is a list of up to 5 important models that should be listed in the header.
    # Defaults to the first five models, whatever they happen to be.
    :header_models => []
  }
  
  Merb::BootLoader.before_app_loads do
    require "mime/types"
    # Let apps include ActiveAdminModel module in its Sequel models
    require "merb_active_admin/active_admin"
  end
  
  Merb::BootLoader.after_app_loads do
    # Fail with an intelligent message if Sequel is not installed
    unless Object.const_defined?("Sequel")
      raise "Merb ActiveAdmin requires that the Sequel ORM be installed."
    end
    
    # Set default important models
    Merb.active_admin_default_header_models
    
    # Register route
    Merb::Router.prepend do |r|
      base_path = Merb::Plugins.config[:merb_active_admin][:base_path]
      # Match anything for resource and file fetching within our pseudo-public dir.
      # Regexp matched routes cannot be named routes, so we have some helper methods in Base.
      r.match(%r{^/#{Regexp.escape(base_path)}/public/(.*)$}).
        to(:controller => "active_admin/assets", :action => "public", :file => "[1]")

      r.match(%r{^/#{Regexp.escape(base_path)}/stylesheet/(.*)$}).
        to(:controller => "active_admin/assets", :action => "stylesheet", :file => "[1]")

      r.match(%r{^/#{Regexp.escape(base_path)}/javascript/(.*)$}).
        to(:controller => "active_admin/assets", :action => "javascript", :file => "[1]")

      # Next, match the home page...
      r.match("/#{base_path}").
        to(:controller => "active_admin/base", :action => "index")
      
      # List data for associations, e.g. /active_admin/users-to-posts/1,2
      r.match(%r{^/#{Regexp.escape(base_path)}/([^/]+)-to-([^/]+)/(.+)$}).
        to(:controller => "active_admin/[1]", :action => "list_association",
           :association => "[2]", :id => "[3]")

      # Create associations, e.g. /active_admin/users/1/associate/posts/1,2,3
      r.match(%r{^/#{Regexp.escape(base_path)}/([^/]+)/([^/]+)/associate/(\w+)/(.+)$}).
        to(:controller => "active_admin/[1]", :action => "associate",
           :id => "[2]", :association => "[3]", :assoc_ids => "[4]")

      # Remove associations, e.g. /active_admin/users/1/disassociate/posts/1,2,3
      r.match(%r{^/#{Regexp.escape(base_path)}/([^/]+)/([^/]+)/disassociate/(\w+)/(.+)$}).
        to(:controller => "active_admin/[1]", :action => "disassociate",
           :id => "[2]", :association => "[3]", :assoc_ids => "[4]")
      
      # ... 'destroy' action with multiple ids, e.g. /active_admin/users/destroy/3,21
      r.match(%r{^/#{Regexp.escape(base_path)}/([^/]+)/destroy/(.+)$}).
        to(:controller => "active_admin/[1]", :action => "destroy", :ids => "[2]")

      # ... actions without ID, e.g. /active_admin/users/list
      r.match("/#{base_path}/:controller/:action").
        to(:controller => "active_admin/:controller")

      # ... actions with ID, e.g. /active_admin/users/update/1
      r.match("/#{base_path}/:controller/:action/:id").
        to(:controller => "active_admin/:controller")


    end
    
    # Load and register the admin controller
    require "merb_active_admin/controllers/active_admin/base"
    require "merb_active_admin/controllers/active_admin/assets"
    ActiveAdmin.make_scaffold!
  end
  
  Merb::Plugins.add_rakefiles "merb_active_admin/merbtasks"
end