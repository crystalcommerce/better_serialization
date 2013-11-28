module BetterSerialization
  class DefaultObjectBuilder
    attr_reader :raw_attrs
    def initialize(raw_attrs)
      @raw_attrs = raw_attrs
    end

    def build(options = {})
      class_name = options[:class_name]

      attr_hash = raw_attrs

      if class_name.blank? || class_includes_root_in_json?(class_name)
        class_name = attr_hash.keys.first.camelcase
        attr_hash = attr_hash.values.first
      end

      class_name ||= options[:attribute].to_s.singularize.camelize

      create(class_name.constantize, attr_hash.with_indifferent_access)
    end

  private

    def active_record?(klass)
      k = klass.superclass
      while k != Object
        return true if k == ActiveRecord::Base
        k = k.superclass
      end
      false
    end

    def class_includes_root_in_json?(class_name)
      return false unless class_name.present?
      klass = class_name.constantize
      active_record?(class_name.constantize) &&
        klass.include_root_in_json
    end

    def create(klass, attr_hash)
      if active_record?(klass)
        klass.instantiate(attr_hash)
      else
        klass.new(attr_hash)
      end
    end
  end
end
