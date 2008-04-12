module ActiveAdmin
  class Assets < Base
    # Create a pseudo-public directory so that we can mount active_admin at any
    # subdirectory on the URL.  This permits us to respect Merb::Plugins.config's
    # base_path setting.
    PSEUDO_PUBLIC_DIR = File.join(ACTIVE_ADMIN_ROOT, "pseudo_public")
    
    # Dynamically transfer images and other files
    def public(file)
      mime_type = MIME::Types.of(file)
      headers["Content-Type"] = mime_type
      File.open(File.join(PSEUDO_PUBLIC_DIR, file), "r")
    end
    
    # Dynamically create a stylesheet
    def stylesheet(file)
      self.content_type = :css
      active_admin_render(file, "css", false)
    end
  end
end