class Fish < ActiveRecord::Base
  EXAGGERATION_RATIO = 10

  class ExaggeratedWeightBuilder
    attr_reader :real_weight

    def initialize(h)
      @real_weight = h['real_talk']
    end

    def build(*)
      real_weight * EXAGGERATION_RATIO
    end
  end

  class RealisticWeightEncoder
    attr_reader :exaggerated_weight

    def initialize(exaggerated_weight)
      @exaggerated_weight = exaggerated_weight
    end

    def as_json(*)
      {'real_talk' => exaggerated_weight / EXAGGERATION_RATIO}
    end
  end

  json_serialize :weight, :object_builder => ExaggeratedWeightBuilder,
                          :object_encoder => RealisticWeightEncoder

end
