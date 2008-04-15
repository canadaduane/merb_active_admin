# make sure we're running inside Merb
if defined?(Merb::Plugins)

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
    hm = Merb::Plugins.config[:merb_active_admin][:header_models]
    hm.replace ActiveAdmin.registered_models[0..4] if hm.empty?
    
    # Register route
    Merb::Router.prepend do |r|
      base_path = Merb::Plugins.config[:merb_active_admin][:base_path]
      # Match anything for resource and file fetching within our pseudo-public dir.
      # Regexp matched routes cannot be named routes, so we have some helper methods in Base.
      r.match(%r{^/#{Regexp.escape(base_path)}/public/(.*)$}).
        to(:controller => "active_admin/assets", :action => "public", :file => "[1]")

      r.match(%r{^/#{Regexp.escape(base_path)}/stylesheet/(.*)$}).
        to(:controller => "active_admin/assets", :action => "stylesheet", :file => "[1]")

      # Next, match the home page...
      r.match("/#{base_path}").
        to(:controller => "active_admin/base", :action => "index").
        name(:active_admin_home)
      
      # ... 'destroy' action with multiple ids
      r.match(%r{^/#{Regexp.escape(base_path)}/([^/]+)/(destroy)/(.+)$}).
        to(:controller => "active_admin/[1]", :action => "[2]", :ids => "[3]")

      # ... actions without ID ...
      r.match("/#{base_path}/:controller/:action").
        to(:controller => "active_admin/:controller")

      # ... actions with ID ...
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