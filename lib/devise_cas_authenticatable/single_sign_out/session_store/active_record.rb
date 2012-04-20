module DeviseCasAuthenticatable
  module SingleSignOut
    class << self
      def destroy_session session_id
        if session = ActiveRecord::SessionStore.session_class.find_by_session_id(session_id)
          session.destroy
        end
      end
    end
  end
end

ActiveRecord::SessionStore.class_eval do
  include DeviseCasAuthenticatable::SingleSignOut::SetSession
  alias_method_chain :set_session, :storage
end
