require 'zlib'

module BetterSerialization
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
  
  def json_serialize(*attrs)
    options = attrs.last.is_a?(Hash) ? attrs.pop : {}
    
    attrs.each do |attribute|
      define_method "#{attribute}=" do |value|
        json = value.to_json(:with => :id)
        json = Zlib::Deflate.deflate(json) if options[:gzip]
        super(json)
      end
      
      define_method attribute do
        return nil if self[attribute].nil?
        
        json = Zlib::Inflate.inflate(self[attribute]) if options[:gzip]
        decoded = ActiveSupport::JSON.decode(json || self[attribute])
        attribute_hashes = [decoded].flatten
        
        result = []
        attribute_hashes.each do |attr_hash|
          class_name = options[:class_name] || attribute.to_s.singularize.camelize
          result << class_name.constantize.new(attr_hash)
        end
        
        return decoded.is_a?(Array) ? result : result.first
      end
    end
  end
end

class ActiveRecord::Base
  extend BetterSerialization
end

