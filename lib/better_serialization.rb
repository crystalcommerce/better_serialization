require 'zlib'
require_relative 'better_serialization/version'

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
      class_name.present? &&
        active_record?(class_name.constantize) &&
        ActiveRecord::Base.include_root_in_json
    end

    def create(klass, attr_hash)
      if active_record?(klass)
        klass.send(:instantiate, attr_hash)
      else
        klass.send(:new, attr_hash)
      end
    end
  end

  # === Options
  # * +gzip+ - uses gzip before marshalling and unmarshalling. Slight speed hit,
  #   but can save a lot of hard drive space.
  def marshal_serialize(*attrs)
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}

    attrs.each do |attribute|
      define_method "#{attribute}=" do |value|
        marshalled_value = Marshal.dump(value)
        marshalled_value = Zlib::Deflate.deflate(marshalled_value) if options[:gzip]
        super(marshalled_value)
      end

      define_method attribute do
        return nil if self[attribute].nil?

        value = Zlib::Inflate.inflate(self[attribute]) if options[:gzip]
        Marshal.load(value || self[attribute])
      end
    end
  end

  # === Options
  # options is the last parameter (a hash):
  # * +:gzip+ - uses gzip before and after serialization. Slight speed hit,
  #   but can save a lot of hard drive space.
  # * +:instantiate+ - if false, it will return the raw decoded json and not attempt to
  #   instantiate ActiveRecord objects. Defaults to true.
  # * +:with_indifferent_access+ - if true, it will return the raw decoded json as
  #   a hash with indifferent access. This can be handy because json doesn't have a concept
  #   of symbols, so it gets annoying when you're using a field as a key-value store
  # * +:default+ - A proc that gets called when the field is null
  # * +:class_name+ - If ActiveRecord::Base.include_root_in_json is false, you
  #   will need this option so that we can figure out which AR class to instantiate
  #   (not applicable if +raw+ is true)
  def json_serialize(*attrs)
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}
    options = {
      :instantiate => true
    }.merge(options)

    attrs.each do |attribute|
      define_method "#{attribute}=" do |value|
        self[attribute] = JsonSerializer.new(options).to_json(value)
      end

      define_method attribute do
        JsonSerializer.new(options).from_json(self[attribute])
      end

      json_serialized_attributes[attribute.to_s] = options
    end
  end

  def json_serialized_attributes
    @json_serialized_attributes ||= {}
  end
end

class ActiveRecord::Base
  extend BetterSerialization
end

