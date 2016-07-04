require 'celluloid/extras/hash'

module Reel
  module Session
    class Store

      def initialize request

        @store = initialize_store
        @request = request
        @key = get_key
        # getting value from key or generating new value
        @val = get_val(@key) || {}
      end

      attr_reader :val

      def get_key
        @config = @request.session_config
        # extracting key from cookie
        if cookie = @request.headers[COOKIE_KEY]
          cookie.split(';').each do |all_cookie|
            array_val = all_cookie.split('=').map &:strip
            return array_val[1] if array_val[0] ==  @config[:session_name]
          end
        end
      end

      def generate_id
        Celluloid::Internals::UUID.generate
      end

      # timer to delete value from concurrent hash/timer hash after expiry
      def start_timer
        timer_hash = Reel::Session.timers_hash
        if timer_hash.key? @key
          timer_hash[@key].reset if timer_hash[@key] && timer_hash[@key].respond_to?(:reset)
        else
          delete_time = @request.connection.server.after(@config[:session_length]){
            delete_from_store @key
            timer_hash.delete @key
          }
          timer_hash[@key] = delete_time
        end
      end

      def save
          # merge key,value
          @key ||= generate_id
          store_save @key,@val
          start_timer
          @key
      end

      def initialize_store
        raise NotImplementedError
      end

      def get_val key
        raise NotImplementedError
      end

      def store_save key,val
        raise NotImplementedError
      end

      def delete_from_store key
        raise NotImplementedError
      end

    end
  end
end
