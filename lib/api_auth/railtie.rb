module ApiAuth

  # Integration with Rails
  #
  class Rails # :nodoc:
    
    module ControllerMethods # :nodoc:
      
      module InstanceMethods # :nodoc:
        
        def get_api_access_id_from_request
          ApiAuth.access_id(request)
        end
        
        def api_authenticated?(secret_key)
          ApiAuth.authentic?(request, secret_key)
        end
        
      end
      
      unless defined?(ActionController)
        begin
          require 'rubygems'
          gem 'actionpack'
          gem 'activesupport'
          require 'action_controller'
          require 'active_support'
        rescue
          nil
        end
      end
      
      if defined?(ActionController::Base)        
        ActionController::Base.send(:include, ControllerMethods::InstanceMethods)
      end
      
    end # ControllerMethods
  
  end # Rails
  
end # ApiAuth
