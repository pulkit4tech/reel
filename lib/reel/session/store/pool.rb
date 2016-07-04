module Reel
  module Session
    class Store
      def initialize_store
        Reel::Session.store
      end

      def get_val key
        @store[key]
      end

      def store_save key,val
        @store.merge!({key=>val})
      end

      def delete_from_store key
        @store.delete(key)
      end
    end
  end
end