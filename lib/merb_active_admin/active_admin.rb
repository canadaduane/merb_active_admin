module ActiveAdmin
  @@models = []
  ACTIVE_ADMIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))
  CONTROLLER_TEMPLATE = File.join(ACTIVE_ADMIN_ROOT, "controller.template.rb")
  
  def self.registered_models
    @@models
  end
  
  # Keeps track of which models are registered ActiveAdmin modules
  def self.included(receiver)
    @@models << receiver
    puts "Registered #{receiver} as an ActiveAdmin Sequel model."
  end
  
  # Loads the controller template file and substitutes +locals+ keys for values
  def self.action_template(locals = {})
    @action_template ||= IO.read(CONTROLLER_TEMPLATE)
    locals.to_a.inject(@action_template){ |text, pair| text.gsub(":#{pair.first}", pair.last) }
  end

  # Adds a controller class for each model that is registered as an ActiveAdmin model
  def self.make_scaffold!
    for receiver in @@models
      module_eval action_template(:model_class => receiver.to_s, :controller_class => "#{receiver}s")
    end
  end
end