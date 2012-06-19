module Rack
  class Request
    def subdomains(tld_len=1) # we set tld_len to 1, use 2 for co.uk or similar
      # cache the result so we only compute it once.
      @env['rack.env.subdomains'] ||= lambda {
        # check if the current host is an IP address, if so return an empty array
        return [] if (host.nil? ||
                      /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
        host.split('.')[0...(1 - tld_len - 2)] # pull everything except the TLD
      }.call
    end
  end
end

module DeviseCasAuthenticatable
  module SingleSignOut
    class StoreSessionId
      def initialize(app)
        @app = app
      end

      def call(env)
        store_session_id_for_cas_ticket(env)
        @app.call(env)
      end

      private

      def store_session_id_for_cas_ticket(env)
        request = Rack::Request.new(env)
        session = request.session

        if session['cas_last_valid_ticket_store']
          sid = env['rack.session.options'][:id]
          Rails.logger.info "Rack: Storing sid #{sid} for ticket #{session['cas_last_valid_ticket']}"

          session_index = session['cas_last_valid_ticket']
          Rails.cache.write(session_index, [request.subdomains, "devise_cas_authenticatable",session_index].flatten.compact.join(':'))

          ::DeviseCasAuthenticatable::SingleSignOut::Strategies.current_strategy.store_session_id_for_index(session_index, sid)
          session['cas_last_valid_ticket_store'] = false
        end
      end

    end
  end
end