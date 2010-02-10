ActiveRecord::Schema.define do
  create_table :order_logs do |t|
    t.text "customer_cache"
    t.text "product_cache"
    t.binary "line_items_cache"
  end

  create_table :customers do |t|
    t.string "name"
  end

  create_table :products do |t|
    t.string "name"
  end

  create_table :line_items do |t|
    t.integer "product_id"
    t.integer "customer_id"
  end

  create_table :directories do |t|
    t.binary "people"
  end
end
