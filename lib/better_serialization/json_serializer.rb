module BetterSerialization
  class JsonSerializer
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def to_json(object)
      json = object_encoder.new(object).to_json
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

    def object_builder
      options.fetch(:object_builder)
    end

    def object_encoder
      options.fetch(:object_encoder)
    end

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
      attribute_hashes.map do |attr_hash|
        object_builder.new(attr_hash).build(options.merge(:attribute => attribute))
      end
    end
  end
end
