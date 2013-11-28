require File.dirname(__FILE__) + '/spec_helper'

describe BetterSerialization do
  let(:order_log) { OrderLog.new }
  let(:li) { LineItem.new }
  let(:product) { Product.new(:name => "Woot", :line_items => [li]) }
  before { li.product = product }

  def swap_include_root_in_json_for(klass, new_value, &block)
    old_value = klass.include_root_in_json
    begin
      klass.include_root_in_json = new_value
      block.call
    ensure
      klass.include_root_in_json = old_value
    end
  end

  describe "json serialization" do
    let(:customer) { Customer.new(:name => "John Spartan") }

    before do
      order_log.customer_cache = customer
    end

    it "serializes the attribute" do
      order_log[:customer_cache].should == customer.to_json
    end

    it "deserializes the attribute" do
      order_log.customer_cache.attributes.should == customer.attributes
    end

    it "works with arrays (and gzip)" do
      OrderLog.json_serialize :line_items_cache, :class_name => "LineItem", :gzip => true
      order_log.line_items_cache = [li]
      @serialized_gzip_li = Zlib::Deflate.deflate([li].to_json)

      order_log.save
      order_log.reload
      order_log[:line_items_cache].should == @serialized_gzip_li
      order_log.line_items_cache.first.attributes.should == li.attributes

      OrderLog.marshal_serialize :line_items_cache, :gzip => true
    end

    it "works with ActiveRecord::Base.include_root_in_json == true" do
      ActiveRecord::Base.include_root_in_json = true

      order_log.customer_cache = customer

      order_log[:customer_cache].should == customer.to_json
      order_log.customer_cache.attributes.should == customer.attributes
    end

    it "works when a model's include_root_in_json disagrees with base's" do
      swap_include_root_in_json_for(ActiveRecord::Base, false) do
        swap_include_root_in_json_for(Customer, true) do
          order_log.customer_cache = customer

          order_log[:customer_cache].should == customer.to_json
          order_log.customer_cache.attributes.should == customer.attributes
        end
      end
    end

    it "includes :id in serialization" do
      customer.save

      order_log.customer_cache = customer
      @serialized_customer = customer.to_json

      order_log.customer_cache.attributes.should == customer.attributes
      order_log.customer_cache.id.should == customer.id
    end

    context "includes :id in a subclass of a subclass of ActiveRecord::Base" do
      context "STI" do
        before do
          $DBG = true
          customer = PreferredCustomer.new(:name => "Lt. Lenina Huxley")
          order_log = OrderLog.new
        end

        it "includes :id when deserialized" do
          customer.save

          order_log.customer_cache = customer
          order_log.customer_cache.id.should == customer.id
          $DBG = false
        end
      end
    end

    context "on a non-ActiveRecord object" do
      let(:directory){ Directory.new }

      it "unserializes the same" do
        person = Person.new(:name => "Simon Phoenix", :age => 75)
        directory.people = [person]
        directory.people.first.should == person
      end
    end
  end

  describe "Marshal serialization" do
    before do
      order_log.product_cache = product
      @serialized_product = Marshal.dump(product)
    end

    it "serializes the input of attribute=" do
      order_log[:product_cache].should == @serialized_product
    end

    it "deserializes the input of attribute=" do
      # can't compare them directly 'cuz they have different object ids
      order_log.product_cache.attributes.should == product.attributes
    end
  end

  describe "Marshal serialization with gzip" do
    before do
      order_log.line_items_cache = [li]
      @serialized_gzip_li = Zlib::Deflate.deflate(Marshal.dump([li]))

      # testing putting binary data in the database
      order_log.save
      order_log.reload
    end

    it "serializes the input of attribute=" do
      order_log[:line_items_cache].should == @serialized_gzip_li
    end

    it "deserializes the input of attribute=" do
      order_log.line_items_cache.first.attributes.should == li.attributes
    end
  end
end
