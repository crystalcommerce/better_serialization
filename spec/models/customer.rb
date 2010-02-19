class Customer < ActiveRecord::Base
  has_many :line_items
end

class PreferredCustomer < Customer
end
