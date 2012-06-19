module DeviseCasAuthenticatable
  module SingleSignOut
    module Strategies
      class RailsCache < Base
        class << self
          attr_accessor :namespace
        end

        def store_session_id_for_index(session_index, session_id)
          logger.debug("RailsCache: Storing #{session_id} for index #{cache_key(session_index)}")
          Rails.cache.write(cache_key(session_index), session_id)
        end

        def find_session_id_by_index(session_index)
          sid = Rails.cache.read(cache_key(session_index))
          logger.debug("RailsCache: Found session id #{sid} for index #{cache_key(session_index)}")
          sid
        end

        def delete_session_index(session_index)
          Rails.cache.delete(cache_key(session_index))
          logger.debug("RailsCache: Deleting index #{cache_key(session_index)}")
        end

        private

        def cache_key(session_index)
          Rails.cache.read session_index
        end
      end
    end
  end
end

::DeviseCasAuthenticatable::SingleSignOut::Strategies.add( :rails_cache, DeviseCasAuthenticatable::SingleSignOut::Strategies::RailsCache )