class Directory < ActiveRecord::Base
  json_serialize :people, :class_name => 'Person'
end
