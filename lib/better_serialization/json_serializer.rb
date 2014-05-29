module BetterSerialization
  class JsonSerializer
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def to_json(object)
      json = object.to_json
      json = Zlib::Deflate.deflate(json) if options[:gzip]
      json
    end

    def from_json(attribute)
      return options[:default].try(:call) if attribute.nil?

      json = deflate(attribute)
      decoded = ActiveSupport::JSON.decode(json)

      if options[:with_indifferent_access]
        return decoded.respond_to?(:with_indifferent_access) ? decoded.with_indifferent_access : decoded
      end
      return decoded if !options[:instantiate]

      result = deserialize(attribute, [decoded].flatten)
      return decoded.is_a?(Array) ? result : result.first
    end

    private

    def deflate(attribute)
      if options[:gzip]
        # Backwards compatibility so we can migrate to base64 encoded gzipped
        # columns.
        if attribute =~ /\A[A-Za-z0-9+\/\n]+={0,3}\Z/
          Zlib::Inflate.inflate(Base64.decode64(attribute))
        else
          Zlib::Inflate.inflate(attribute)
        end
      else
        attribute
      end
    end

    def deserialize(attribute, attribute_hashes)
      class_name = options[:class_name]
      attribute_hashes.inject([]) do |result, attr_hash|
        if class_name.blank? || class_included?(class_name)
          class_name = attr_hash.keys.first.camelcase
          attr_hash = attr_hash.values.first
        end
        class_name ||=  attribute.to_s.singularize.camelize

        result << create(class_name.constantize, attr_hash.with_indifferent_access)
      end
    end

    def active_record?(klass)
      k = klass.superclass
      while k != Object
        return true if k == ActiveRecord::Base
        k = k.superclass
      end
      false
    end

    def class_included?(class_name)
      return false unless class_name.present?
      klass = class_name.constantize
      active_record?(class_name.constantize) &&
        klass.include_root_in_json
    end

    def create(klass, attr_hash)
      if active_record?(klass)
        klass.send(:instantiate, attr_hash)
      else
        klass.send(:new, attr_hash)
      end
    end
  end
end
