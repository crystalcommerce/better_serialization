require 'zlib'

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
  #   instantiate ActiveRecord objects. Defaults to true
  # * +:class_name+ - If ActiveRecord::Base.include_root_in_json is false, you
  #   will need this option so that we can figure out which AR class to instantiate
  #   (not applicable if +raw+ is true)
  def json_serialize(*attrs)
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}
    options = {:instantiate => true}.merge(options)
    
    attrs.each do |attribute|
      define_method "#{attribute}=" do |value|
        json = value.to_json
        json = Zlib::Deflate.deflate(json) if options[:gzip]
        super(json)
      end
      
      define_method attribute do
        return nil if self[attribute].nil?
        
        json = options[:gzip] ? Zlib::Inflate.inflate(self[attribute]) : self[attribute]
        decoded = ActiveSupport::JSON.decode(json)
        
        return decoded if !options[:instantiate]
        
        attribute_hashes = [decoded].flatten
        
        result = []
        attribute_hashes.each do |attr_hash|
          if ActiveRecord::Base.include_root_in_json
            class_name = attr_hash.keys.first.camelcase
            attr_hash = attr_hash.values.first
          end
          class_name ||= options[:class_name] || attribute.to_s.singularize.camelize
          result << class_name.constantize.send(:instantiate, attr_hash)
        end
        
        return decoded.is_a?(Array) ? result : result.first
      end
    end
  end
end

class ActiveRecord::Base
  extend BetterSerialization
end

