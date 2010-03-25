module Zafu

  if RUBY_VERSION.split('.')[0..1].join('.').to_f > 1.8
    OrderedHash = Hash
  else
    class OrderedHash < Hash

      def []=(k, v)
        keys << k unless keys.include?(k)
        super
      end

      def merge!(hash)
        hash.keys.each do |k|
          keys << k unless keys.include?(k)
        end
        super
      end

      alias o_keys keys
      def keys
        @keys ||= o_keys
      end

      def each
        keys.each do |k|
          yield(k, self[k])
        end
      end

      def delete(k)
        keys.delete(k)
        super
      end
    end
  end
end