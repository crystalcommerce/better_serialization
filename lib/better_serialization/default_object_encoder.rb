module BetterSerialization
  class DefaultObjectEncoder
    attr_reader :object

    def initialize(object)
      @object = object
    end

    def as_json(*args)
      object.as_json(*args)
    end
  end
end
