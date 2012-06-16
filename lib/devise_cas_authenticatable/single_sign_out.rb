module DeviseCasAuthenticatable
  module SingleSignOut

    def self.rails3?
      defined?(::Rails) && ::Rails::VERSION::MAJOR == 3
    end

    # Supports destroying sessions by ID for ActiveRecord and Redis session stores
    module destroy_session_by_id
      def session_store_class
        @session_store_class ||=
          begin
            if ::DeviseCasAuthenticatable::SingleSignOut.rails3?
              ::Rails.application.config.session_store
            else
              ActionController::Base.session_store
            end
          rescue NameError => e
            ActionController::Base.session_options[:database_manager]
          end
      end

      def current_session_store
        if ::DeviseCasAuthenticatable::SingleSignOut.rails3?
          session_store_class.new :app, Rails.application.config.session_options
        else
          session_store_class.new :app, ActionController::Base.session_options
        end
      end

      def destroy_session_by_id(sid)
        if (defined?(ActiveRecord) && session_store_class == ActiveRecord::SessionStore)
          Rails.logger.debug "ActiveRecord::SessionStore logout"
          session = current_session_store::Session.find_by_session_id(sid)
          session.destroy if session
          true
        elsif session_store_class.name =~ /RedisSessionStore/
          Rails.logger.debug "RedisSessionStore logout"
          if ::DeviseCasAuthenticatable::SingleSignOut.rails3?
            pool = current_session_store.instance_variable_get(:@pool)
            pool && pool.del(sid)
          else
            current_session_store.destroy_with_sid sid
          end
          true
        elsif session_store_class.name =~ /RedisStore/
          Rails.logger.debug "RedisStore logout"
          pool = current_session_store.instance_variable_get(:@pool)
          pool && pool.del(sid)
          true
        else
          Rails.logger.error "Cannot process logout request because this Rails application's session store is "+
                " #{current_session_store.name.inspect} and is not a support session store type for Single Sign-Out."
          false
        end
      end
    end

  end
end

require 'devise_cas_authenticatable/single_sign_out/strategies'
require 'devise_cas_authenticatable/single_sign_out/strategies/base'
require 'devise_cas_authenticatable/single_sign_out/strategies/rails_cache'
require 'devise_cas_authenticatable/single_sign_out/rack'