require 'rubygems'
require 'spec'
require 'ruby-debug'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
 
require 'activerecord'
require File.dirname(__FILE__) + '/../lib/better_serialization'

RAILS_ENV="test"
 
ActiveRecord::Base.configurations = {
  "test" => {
    :adapter => 'sqlite3',
    :database => ":memory:"
  }
}
ActiveRecord::Base.establish_connection
silence_stream(STDOUT) {require 'schema'}

require "models/order_log"
require "models/customer"
require "models/line_item"
require "models/product"
