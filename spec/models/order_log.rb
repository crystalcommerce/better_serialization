class OrderLog < ActiveRecord::Base
  marshal_serialize :line_items_cache, :gzip => true
  marshal_serialize :product_cache
  json_serialize :customer_cache, :class_name => "Customer"
end
