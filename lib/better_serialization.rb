require 'zlib'
require_relative 'better_serialization/version'
require_relative 'better_serialization/json_serializer'
require_relative 'better_serialization/default_object_builder'
require_relative 'better_serialization/default_object_encoder'

module BetterSerialization
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
  # * +:object_builder+ - A class that will be initialized with the attributes of each
  #   deserialized object. It must respond to #build which will create an instance of the
  #   fully deserialized object. Build will be sent the options hash from better_serialization
  # * +:object_encoder+ - A class that will be initialized with each object. It must respond
  #   to #as_json.
  # * +:class_name+ - If ActiveRecord::Base.include_root_in_json is false, you
  #   will need this option so that we can figure out which AR class to instantiate
  #   (not applicable if +raw+ is true)
  def json_serialize(*attrs)
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}
    options = {
      :instantiate    => true,
      :object_builder => DefaultObjectBuilder,
      :object_encoder => DefaultObjectEncoder
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

